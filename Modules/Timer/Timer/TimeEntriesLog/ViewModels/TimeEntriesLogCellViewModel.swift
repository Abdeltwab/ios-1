import Foundation
import RxCocoa
import RxSwift
import RxDataSources

enum TimeEntriesLogCellViewModel: IdentifiableType, Equatable {
    case timeEntryCell(TimeEntryCellViewModel)
    case suggestionCell(LogSuggestionViewModel)
    
    public var identity: String {
        switch self {
        case let .timeEntryCell(timeEntryCellViewModel):
            return "TimeEntry: \(timeEntryCellViewModel.id)"
        case let .suggestionCell(logSuggestionViewModel):
            return "Suggestion: \(logSuggestionViewModel.identifier)"
        }
    }
}
