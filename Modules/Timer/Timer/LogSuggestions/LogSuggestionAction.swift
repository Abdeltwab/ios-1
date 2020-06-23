import Foundation
import Models
import CommonFeatures

public enum LogSuggestionAction: Equatable {
    case loadSuggestions
    case suggestionTapped(LogSuggestion)
    case suggestionLoaded([LogSuggestion])
    case timeEntries(TimeEntriesAction)
}

extension LogSuggestionAction {
    var timeEntries: TimeEntriesAction? {
        get {
            guard case let .timeEntries(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeEntries = self, let newValue = newValue else { return }
            self = .timeEntries(newValue)
        }
    }
}

extension LogSuggestionAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .loadSuggestions:
            return "LoadSuggestions"
            
        case .suggestionTapped(let suggestion):
            return "SuggestionTapped: \(suggestion)"

        case .suggestionLoaded(let suggestions):
            return "SuggestionLoaded: \(suggestions)"

        case let .timeEntries(action):
            return action.debugDescription
        }
    }
}
