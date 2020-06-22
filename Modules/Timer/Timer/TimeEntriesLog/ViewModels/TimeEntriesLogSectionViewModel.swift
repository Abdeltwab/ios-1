import Foundation
import RxCocoa
import RxSwift
import RxDataSources

enum TimeEntriesLogSectionViewModel: Equatable, AnimatableSectionModelType {
    case day(DayViewModel)
    case suggestions([TimeEntriesLogCellViewModel])
    
    public init(original: TimeEntriesLogSectionViewModel, items: [TimeEntriesLogCellViewModel]) {
        switch original {
        case let .day(dayViewModel):
            var newDayViewModel = dayViewModel
            newDayViewModel.timeLogCells = items
            self = .day(newDayViewModel)
        case let .suggestions(suggestions):
            self = .suggestions(suggestions)
        }
    }
    
    public var title: String {
        switch self {
        case let .day(dayViewModel):
            return dayViewModel.dayString
        case .suggestions:
            return "Suggestions"
        }
    }
    
    public var identity: String { title }
    
    public var items: [TimeEntriesLogCellViewModel] {
        switch self {
        case let .day(dayViewModel):
            return dayViewModel.timeLogCells
        case let .suggestions(suggestions):
            return suggestions
        }
    }
    
    static func == (lhs: TimeEntriesLogSectionViewModel, rhs: TimeEntriesLogSectionViewModel) -> Bool {
        switch (lhs, rhs) {
        case (let .day(lDayViewModel), let .day(rDayViewModel)):
            return lDayViewModel == rDayViewModel
        case (let .suggestions(lSuggestions), let .suggestions(rSuggestions)):
            return lSuggestions == rSuggestions
        default:
            return false
        }
    }
}
