import UIKit
import Utils
import UIUtils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias TimeEntriesLogStore = Store<TimeEntriesLogState, TimeEntriesLogAction>

public class TimeEntriesLogViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Timer"
    public static var storyboardBundle = Assets.bundle

    @IBOutlet weak var tableView: UITableView!

    private var disposeBag = DisposeBag()
    private var dataSource: RxTableViewSectionedAnimatedDataSource<DayViewModel>!
    private var snackbar: Snackbar?

    public var store: TimeEntriesLogStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Toggl"
        tableView.rowHeight = 72
    }

    // swiftlint:disable function_body_length
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if dataSource == nil {
            // We should do this in ViewDidLoad, but there's a bug that causes an ugly warning. That's why we are doing it here for now
            dataSource = RxTableViewSectionedAnimatedDataSource<DayViewModel>(
                configureCell: { [weak self] _, tableView, indexPath, item in
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeEntryCell", for: indexPath) as? TimeEntryCell else {
                        fatalError("Wrong cell type")
                    }
                    cell.descriptionLabel.text = item.description
                    cell.descriptionLabel.textColor = item.descriptionColor
                    cell.projectClientTaskLabel.textColor = item.projectColor
                    cell.projectClientTaskLabel.attributedText = item.projectTaskClient
                    cell.durationLabel.text = item.durationString
                    cell.continueButton.rx.tap
                        .mapTo(TimeEntriesLogAction.continueButtonTapped(item.mainEntryId))
                        .subscribe(onNext: self?.store.dispatch)
                        .disposed(by: cell.disposeBag)
                    cell.hasTagsImageView.isHidden = item.tags?.isEmpty ?? true
                    cell.isBillableImage.isHidden = item.billable
                    return cell
            })

            dataSource.canEditRowAtIndexPath = { _, _ in true }

            dataSource.titleForHeaderInSection = { dataSource, index in
              return dataSource.sectionModels[index].dayString
            }

            Driver.combineLatest(
                store.select(timeEntryViewModelsSelector),
                store.select(expandedGroupsSelector),
                store.select(entriesPendingDeletionSelector),
                resultSelector: toDaysMapper
            )
                .drive(tableView.rx.items(dataSource: dataSource!))
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(TimeLogCellViewModel.self)
                .map { $0.tappedAction }
                .subscribe(onNext: store.dispatch)
                .disposed(by: disposeBag)

            tableView.rx.setDelegate(self)
                .disposed(by: disposeBag)

            store.select(entriesPendingDeletionSelector)
                .map { [weak self] setOfIds -> Snackbar? in
                    self?.snackbar?.dismiss()
                    if setOfIds.count > 0 {
                        self?.snackbar = self?.createSnackbar(for: setOfIds)
                    }
                    return self?.snackbar
                }
                .drive(onNext: { $0?.show(in: self) })
                .disposed(by: disposeBag)
        }
    }

    private func createSnackbar(for setOfIds: Set<Int64>) -> Snackbar {
        return Snackbar.with(
            text: Strings.entriesDeleted(setOfIds.count),
            buttonTitle: Strings.undo,
            store: store,
            action: .undoButtonTapped)
    }
}

extension TimeEntriesLogViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Continue") { _, _, _ in
            let timeLogCellViewModel = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
            self.store.dispatch(timeLogCellViewModel.swipedAction(direction: .right))
        }
        action.backgroundColor = Color.continueAction.uiColor
        return UISwipeActionsConfiguration(actions: [action])
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            let timeLogCellViewModel = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
            self.store.dispatch(timeLogCellViewModel.swipedAction(direction: .left))
        }
        action.backgroundColor = Color.deleteAction.uiColor
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension TimeLogCellViewModel {
    var tappedAction: TimeEntriesLogAction {
        switch self {
        case let .singleEntry(timeEntry, inGroup: _):
            return TimeEntriesLogAction.timeEntryTapped(timeEntry.id)
        case let .groupedEntriesHeader(timeEntries, open: _):
            return TimeEntriesLogAction.timeEntryGroupTapped(timeEntries.map { $0.id })
        }
    }

    func swipedAction(direction: SwipeDirection) -> TimeEntriesLogAction {
        switch self {
        case let .singleEntry(timeEntry, inGroup: _):
            return TimeEntriesLogAction.timeEntrySwiped(direction, timeEntry.id)
        case let .groupedEntriesHeader(timeEntries, open: _):
            return TimeEntriesLogAction.timeEntryGroupSwiped(direction, timeEntries.map { $0.id })
        }
    }
}

// ANIMATED DATASOURCE EXTENSIONS

extension TimeLogCellViewModel: IdentifiableType {
    public var identity: String { id }
}

extension DayViewModel: AnimatableSectionModelType {

    public init(original: DayViewModel, items: [TimeLogCellViewModel]) {
        self = original
        self.timeLogCells = items
    }

    public var identity: Date { day }
    public var items: [TimeLogCellViewModel] { timeLogCells }
}
