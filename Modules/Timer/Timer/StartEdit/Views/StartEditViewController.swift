import UIKit
import Assets
import Utils
import UIUtils
import Architecture
import RxSwift
import RxCocoa
import OtherServices

public typealias StartEditStore = Store<StartEditState, StartEditAction>

public class StartEditViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Timer"
    public static var storyboardBundle = Assets.bundle

    var smallStateHeightSubject = BehaviorSubject<CGFloat>(value: 0)
    var smallStateHeight: Driver<CGFloat> {
        smallStateHeightSubject.asDriver(onErrorJustReturn: 0)
    }

    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var projectAndTagsView: UIView!
    @IBOutlet weak var datePickers: DatePickers!
    @IBOutlet weak var wheel: Wheel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var billableButton: UIButton!

    @IBOutlet var startEditInputAccessoryView: StartEditInputAccessoryView!

    public override var inputAccessoryView: UIView? { startEditInputAccessoryView }

    public var store: StartEditStore!
    public var time: Time!

    private var disposeBag = DisposeBag()
    private var timer: Timer?
    
    // swiftlint:disable function_body_length
    public override func viewDidLoad() {
        super.viewDidLoad()

        handle.layer.cornerRadius = 2

        durationView.layer.cornerRadius = 16
        durationLabel.text = "--:--"

        let cancelDatePickerGesture = UITapGestureRecognizer(target: self, action: #selector(cancelDatePicker))
        cancelDatePickerGesture.delegate = datePickers
        contentScrollView.addGestureRecognizer(cancelDatePickerGesture)

        datePickers.bindStore(store: store)
        wheel.bindStore(store: store)
        startEditInputAccessoryView.bindStore(store: store)

        store.select({ $0.editableTimeEntry })
            .drive(onNext: displayTimeEntry)
            .disposed(by: disposeBag)

        Observable.combineLatest(descriptionTextView.rx.text, descriptionTextView.rx.cursorPosition)
            .do(onNext: { [weak self] _ in self?.focus() })
            .map { [weak self] _ in (self?.descriptionTextView.text ?? "", self?.descriptionTextView.cursorPosition ?? 0)}
            .map(StartEditAction.descriptionEntered)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        projectButton.rx.tap
            .mapTo(StartEditAction.projectButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        tagButton.rx.tap
            .mapTo(StartEditAction.tagButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        billableButton.rx.tap
            .mapTo(StartEditAction.billableButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        store.select({ $0.editableTimeEntry?.billable ?? false })
            .drive(onNext: { isBillable in
                self.billableButton.backgroundColor = isBillable
                    ? UIColor.gray
                    : .white
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .mapTo(StartEditAction.closeButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let minHeight = projectAndTagsView.frame.origin.y + projectAndTagsView.frame.size.height
        smallStateHeightSubject.onNext(minHeight)
    }

    public func loseFocus() {
        descriptionTextView.resignFirstResponder()
        Tooltip.dismiss()
    }

    public func focus() {
        descriptionTextView.becomeFirstResponder()
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }

    public override var canBecomeFirstResponder: Bool { true }

    private func displayTimeEntry(timeEntry: EditableTimeEntry?) {
        guard let timeEntry = timeEntry else {
            descriptionTextView.text = nil
            return
        }

        descriptionTextView.text = timeEntry.description
        setDuration(for: timeEntry)
    }

    private func setDuration(for timeEntry: EditableTimeEntry) {

        timer?.invalidate()
        timer = nil

        guard let start = timeEntry.start else {
            durationLabel.text = "00:00"
            wheel.setDurationString("00:00")
            return
        }

        guard let duration = timeEntry.duration else {
            timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                let formattedDuration = self?.time.now().timeIntervalSince(start).formattedDuration()
                self?.durationLabel.text = formattedDuration
                self?.wheel.setDurationString(formattedDuration)
            }
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
            return
        }

        let formattedDuration = duration.formattedDuration()
        durationLabel.text = formattedDuration
        wheel.setDurationString(formattedDuration)
    }

    @objc private func cancelDatePicker() {
        store.dispatch(.dateTimePickingCancelled)
    }

    deinit {
        timer?.invalidate()
    }
}

extension StartEditViewController: BottomSheetContent {
    var scrollView: UIScrollView? {
        return contentScrollView
    }
    
    var visibility: Driver<Bool> {
        return store.select(shouldShowEditView)
    }

    func dispatchDialogDismissed() {
        store.dispatch(.dialogDismissed)
    }
}
