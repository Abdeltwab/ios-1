import Foundation

enum TimeEntriesLogSectionViewModel: Equatable {
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
    
    case day(DayViewModel)
    case suggestions([LogSuggestionViewModel])
}
