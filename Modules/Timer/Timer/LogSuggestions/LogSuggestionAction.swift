import Foundation
import Models

public enum LogSuggestionAction: Equatable {
    case loadSuggestions
}

extension LogSuggestionAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .loadSuggestions:
            return "LoadSuggestions"

        }
    }
}
