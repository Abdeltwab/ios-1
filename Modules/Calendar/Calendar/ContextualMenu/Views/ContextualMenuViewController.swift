import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models
import CalendarService
import Timer

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

    private var bottomConstraint: NSLayoutConstraint!
    private var height: CGFloat = 238
    private var disposeBag = DisposeBag()

    public var store: ContextualMenuStore!

    // swiftlint:disable function_body_length
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

        store.compactSelect(selectedCalendarItem)
            .drive(onNext: self.configure(with:))
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .mapTo(ContextualMenuAction.cancelButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        discardButton.rx.tap
            .mapTo(ContextualMenuAction.discardButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        copyAsTimeEntryButton.rx.tap
            .mapTo(ContextualMenuAction.copyAsTimeEntryButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        startFromCalendarEventButton.rx.tap
            .mapTo(ContextualMenuAction.startFromEventButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        deleteButton.rx.tap
            .mapTo(ContextualMenuAction.deleteButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        editButton.rx.tap
            .mapTo(ContextualMenuAction.editButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        stopButton.rx.tap
            .mapTo(ContextualMenuAction.stopButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .mapTo(ContextualMenuAction.saveButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        continueButton.rx.tap
            .mapTo(ContextualMenuAction.continueButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    public override func didMove(toParent parent: UIViewController?) {
        guard let parent = parent else { return }

        bottomConstraint = view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor, constant: height)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
            bottomConstraint,
            view.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    private func configure(with viewModel: SelectedCalendarItemViewModel) {
        descriptionLabel.text = viewModel.description
        startAndStopLabel.text = viewModel.formattedStartAndStop
        projectColorView.isHidden = viewModel.projectOrCalendar == nil
        projectNameLabel.isHidden = viewModel.projectOrCalendar == nil
        if viewModel.projectOrCalendar != nil {
            projectColorView.backgroundColor = viewModel.color.flatMap({ UIColor(hex: $0) }) ?? Color.noProject.uiColor
            projectNameLabel.text = viewModel.projectOrCalendar
        }

        discardButton.isHidden = !viewModel.isNewTimeEntry
        copyAsTimeEntryButton.isHidden = !viewModel.isCalendarEvent
        startFromCalendarEventButton.isHidden = !viewModel.isCalendarEvent
        deleteButton.isHidden = !viewModel.isStoppedTimeEntry
        editButton.isHidden = !viewModel.isTimeEntry
        stopButton.isHidden = !viewModel.isRunningTimeEntry
        saveButton.isHidden = !viewModel.isTimeEntry
        continueButton.isHidden = !viewModel.isStoppedTimeEntry
    }

    private func show() {
        guard parent != nil, view.superview != nil else { return }
        bottomConstraint.constant = 0
        tabBarController?.tabBar.isHidden = true
        animateVisibility()
    }

    private func hide() {
        guard parent != nil, view.superview != nil else { return }
        bottomConstraint.constant = height
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
