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
    private var dataSource: RxTableViewSectionedAnimatedDataSource<TimeEntriesLogSectionViewModel>!
    private var snackbar: Snackbar?

    public var store: TimeEntriesLogStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Toggl"
        tableView.rowHeight = 63
        
        tableView.register(TimeLogDayHeader.nib,
                           forHeaderFooterViewReuseIdentifier: TimeLogDayHeader.reuseIdentifier)
        tableView.register(TimeLogSuggestionsHeader.nib,
                           forHeaderFooterViewReuseIdentifier: TimeLogSuggestionsHeader.reuseIdentifier)
        tableView.register(TimeLogSuggestionsFooter.nib,
                           forHeaderFooterViewReuseIdentifier: TimeLogSuggestionsFooter.reuseIdentifier)
    }

    // swiftlint:disable function_body_length
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if dataSource == nil {
            // We should do this in ViewDidLoad, but there's a bug that causes an ugly warning. That's why we are doing it here for now
            dataSource = RxTableViewSectionedAnimatedDataSource<TimeEntriesLogSectionViewModel>(
                configureCell: { [weak self] _, tableView, indexPath, item in
                    switch item {
                    case let .timeEntryCell(cellViewModel):
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TimeEntryCell", for: indexPath) as? TimeEntryCell else {
                            fatalError("Wrong cell type")
                        }
                        cell.descriptionLabel.text = cellViewModel.description
                        cell.descriptionLabel.textColor = cellViewModel.descriptionColor
                        cell.projectClientTaskLabel.textColor = cellViewModel.projectColor
                        cell.projectClientTaskLabel.attributedText = cellViewModel.projectTaskClient
                        cell.durationLabel.text = cellViewModel.durationString
                        cell.continueButton.rx.tap
                            .mapTo(TimeEntriesLogAction.continueButtonTapped(cellViewModel.mainEntryId))
                            .subscribe(onNext: self?.store.dispatch)
                            .disposed(by: cell.disposeBag)
                        cell.hasTagsImageView.isHidden = cellViewModel.tags?.isEmpty ?? true
                        cell.isBillableImage.isHidden = cellViewModel.billable
                        return cell
                    case let .suggestionCell(cellViewModel):
                        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LogSuggestionCell",
                                                                       for: indexPath) as? LogSuggestionCell
                            else {
                            fatalError("Wrong cell type")
                        }
                        cell.descriptionLabel.text = cellViewModel.description
                        cell.projectTaskClientLabel.attributedText = cellViewModel.projectTaskClient
                        return cell
                    }
            })

            dataSource.canEditRowAtIndexPath = { _, _ in true }

            Driver.combineLatest(
                store.select { $0.logSuggestions },
                store.select(timeEntryViewModelsSelector),
                store.select(expandedGroupsSelector),
                store.select(entriesPendingDeletionSelector),
                resultSelector: toSectionsMapper
            )
                .drive(tableView.rx.items(dataSource: dataSource!))
                .disposed(by: disposeBag)

            tableView.rx.modelSelected(TimeEntriesLogCellViewModel.self)
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
        let item = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
        guard case let .timeEntryCell(timeEntryCellViewModel) = item else { return nil }
        let action = UIContextualAction(style: .normal, title: "Continue") { _, _, _ in
            self.store.dispatch(timeEntryCellViewModel.swipedAction(direction: .right))
        }
        action.backgroundColor = Color.continueAction.uiColor
        return UISwipeActionsConfiguration(actions: [action])
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = self.dataSource.sectionModels[indexPath.section].items[indexPath.item]
        guard case let .timeEntryCell(timeEntryCellViewModel) = item else { return nil }
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.store.dispatch(timeEntryCellViewModel.swipedAction(direction: .left))
        }
        action.backgroundColor = Color.deleteAction.uiColor
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch dataSource.sectionModels[section] {
        case .suggestions:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeLogSuggestionsHeader.reuseIdentifier)
            return header
        case let .day(dayViewModel):
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeLogDayHeader.reuseIdentifier) as? TimeLogDayHeader else {
                fatalError("Wrong header type!")
            }
            header.titleLabel.text = dayViewModel.dayString.uppercased()
            header.totalTimeLabel.text = dayViewModel.durationString.uppercased()
            return header
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch dataSource.sectionModels[section] {
        case .suggestions:
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeLogSuggestionsFooter.reuseIdentifier)
            return footer
        case .day:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch dataSource.sectionModels[section] {
        case .suggestions:
            return 44
        case .day:
            return 45
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch dataSource.sectionModels[section] {
        case .suggestions:
            return 46
        case .day:
            return 0
        }
    }
}

extension TimeEntriesLogCellViewModel {
    var tappedAction: TimeEntriesLogAction {
        switch self {
        case let .timeEntryCell(.singleEntry(timeEntry, inGroup: _)):
            return .timeEntryTapped(timeEntry.id)
        case let .timeEntryCell(.groupedEntriesHeader(timeEntries, open: _)):
            return .timeEntryGroupTapped(timeEntries.map { $0.id })
        case let .suggestionCell(suggestionViewModel):
            return .logSuggestions(.suggestionTapped(suggestionViewModel.suggestion))
        }
    }
}

extension TimeEntryCellViewModel {
    func swipedAction(direction: SwipeDirection) -> TimeEntriesLogAction {
        switch self {
        case let .singleEntry(timeEntry, inGroup: _):
            return TimeEntriesLogAction.timeEntrySwiped(direction, timeEntry.id)
        case let .groupedEntriesHeader(timeEntries, open: _):
            return TimeEntriesLogAction.timeEntryGroupSwiped(direction, timeEntries.map { $0.id })
        }
    }
}
