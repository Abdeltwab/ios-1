import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias ContextualMenuStore = Store<ContextualMenuState, ContextualMenuAction>

public class ContextualMenuViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Calendar"
    public static var storyboardBundle = Assets.bundle

    @IBOutlet var startAndStopLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var projectColorView: UIView!
    @IBOutlet var projectNameLabel: UILabel!

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var discardButton: UIButton!
    @IBOutlet var copyAsTimeEntryButton: UIButton!
    @IBOutlet var startFromCalendarEventButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var continueButton: UIButton!

    private var height: CGFloat = 238
    private var disposeBag = DisposeBag()

    public var store: ContextualMenuStore!

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 10
        view.layer.shadowColor = Color.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -6)
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 0.2
        view.clipsToBounds = false

        store.select(shouldShowContextualMenu)
            .drive(onNext: { $0 ? self.show() : self.hide() })
            .disposed(by: disposeBag)
    }

    public override func didMove(toParent parent: UIViewController?) {
        guard let parent = parent else { return }

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: height),
            view.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    private func show() {
        guard let parent = parent, view.superview != nil else { return }
        view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: 0).isActive = true
        tabBarController?.tabBar.isHidden = true
        animateVisibility()
    }

    private func hide() {
        guard let parent = parent, view.superview != nil else { return }
        view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: height).isActive = true
        tabBarController?.tabBar.isHidden = false
        animateVisibility()
    }

    private func animateVisibility() {
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: { self.view.superview?.layoutIfNeeded() },
                       completion: nil)
    }
}
