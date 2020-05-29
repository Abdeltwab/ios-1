import Foundation
import RxSwift
import RxCocoa
import UIKit

class BottomSheetViewController: UIViewController, UIGestureRecognizerDelegate {

    typealias ContainedViewController = UIViewController & BottomSheetContent

    private var topConstraint: NSLayoutConstraint!

    private var fullScreenConstant: CGFloat = 0
    private var hiddenViewConstant: CGFloat = 0

    private var minViewHeight: CGFloat = 0
    private var keyboardHeight: CGFloat = 0
    private var dragAmount: CGFloat = 0

    private let containedViewController: ContainedViewController
    private let overlay = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    private var isDragging = false

    private var disposeBag = DisposeBag()

    var state: BottomSheetState = .hidden {
        didSet {
            layout()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewController: ContainedViewController) {
        containedViewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        view.isOpaque = false

        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        gesture.delegate = self
        containedViewController.view.addGestureRecognizer(gesture)

        Observable.merge(
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
                NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            )
            .map(keyboardIntersectionHeight(notification:))
            .subscribe(onNext: keyboardWillChange(intersectionHeight:))
            .disposed(by: disposeBag)
        
        containedViewController.visibility
            .drive(onNext: { [weak self] isVisible in
                isVisible ? self?.show() : self?.hide()
            })
            .disposed(by: disposeBag)
        
        let navigationController = UINavigationController(rootViewController: containedViewController)
        navigationController.navigationBar.isHidden = true

        install(navigationController, customConstraints: true)

        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        navigationController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let bottomConstraint = navigationController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
        topConstraint = navigationController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        topConstraint.isActive = true

        containedViewController.view.layer.cornerRadius = 10
        containedViewController.view.clipsToBounds = true
        navigationController.view.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        navigationController.view.layer.shadowOffset = CGSize(width: 0, height: -6)
        navigationController.view.layer.shadowRadius = 10.0
        navigationController.view.layer.shadowOpacity = 0.2
        navigationController.view.clipsToBounds = false

        overlay.backgroundColor = UIColor(white: 0, alpha: 0.3)
        overlay.alpha = 0
        view.insertSubview(overlay, at: 0)
        overlay.constraintToParent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topConstraint.constant = view.bounds.height
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fullScreenConstant = 0
        hiddenViewConstant = view.bounds.height

        containedViewController.smallStateHeight
            .drive(onNext: { smallStateHeight in
                self.minViewHeight = smallStateHeight
                self.layout()
            })
            .disposed(by: disposeBag)

        layout()
    }

    private func hide() {
        state = .hidden
        containedViewController.loseFocus()
        containedViewController.resignFirstResponder()
    }

    private func show() {
        state = .partial
        containedViewController.focus()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func layout() {
        guard view.superview != nil else { return }
        
        switch state {
        case .hidden:
            view.isUserInteractionEnabled = false
            topConstraint.constant = hiddenViewConstant + dragAmount
        case .partial:
            view.isUserInteractionEnabled = true
            let viewHeight = view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
            topConstraint.constant = viewHeight - minViewHeight - keyboardHeight + dragAmount
        case .full:
            view.isUserInteractionEnabled = true
            topConstraint.constant = fullScreenConstant + dragAmount
        }

        containedViewController.scrollView?.isScrollEnabled = true
        containedViewController.scrollView?.setContentOffset(.zero, animated: false)

        UIView.animate(withDuration: 0.3) {
            self.overlay.alpha = self.state == .hidden ? 0 : 1
        }
        
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1,
            options: [],
            animations: {
                self.view.superview?.layoutIfNeeded()
        },
            completion: nil)

    }
    
    override func didMove(toParent parent: UIViewController?) {
        
        guard let parent = parent else { return }

        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parent.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc
    func panGesture(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: view).y
        let velocity = recognizer.velocity(in: view).y
        
        switch recognizer.state {
        case .began:
            isDragging = true

        case .changed:
            dragAmount += translation
            layout()
            containedViewController.loseFocus()

        case .ended, .cancelled:
            isDragging = false
            dragAmount = 0
            let finalPosition = self.topConstraint.constant + translation + velocity * 0.1
            if finalPosition < fullScreenConstant + view.frame.height / 2 {
                state = .full
            } else if finalPosition < hiddenViewConstant {
                state = .partial
            } else {
                containedViewController.dispatchDialogDismissed()
            }

            layout()

        default:
            break
        }
        
        recognizer.setTranslation(CGPoint.zero, in: view)
    }

    private func keyboardIntersectionHeight(notification: Notification) -> CGFloat {
        guard let userInfo = notification.userInfo else { return 0 }
        let keyboardFrame =  (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!.cgRectValue

        let keyboardFrameInView = parent!.view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = parent!.view.safeAreaLayoutGuide.layoutFrame
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        return intersection.height
    }

    private func keyboardWillChange(intersectionHeight: CGFloat) {
        let oldKeyboardHeight = keyboardHeight
        keyboardHeight = intersectionHeight

        if isDragging && oldKeyboardHeight > keyboardHeight {
            dragAmount -= oldKeyboardHeight
        }

        layout()
    }

    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard let scrollView = containedViewController.scrollView,
            let gesture = gestureRecognizer as? UIPanGestureRecognizer
            else {
                return false
        }

        if state == .full && !isDragging {
            containedViewController.loseFocus()
        }
        let direction = gesture.velocity(in: view).y

        let yposition = topConstraint.constant
        if (yposition == fullScreenConstant && scrollView.contentOffset.y == 0 && direction > 0) || (state == .partial) {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }

        return false
    }
}
