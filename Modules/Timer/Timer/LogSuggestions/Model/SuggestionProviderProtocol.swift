import Foundation

protocol SuggestionPrivider {
    func getSuggestions() -> [LogSuggestion]
}
