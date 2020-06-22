import Foundation

public enum CalendarSuggestionProviderState: String {
    case unauthorized = "Unauthorized"
    case noEvents = "NoEvents"
    case suggestionsAvailable = "SuggestionsAvailable"
}

public enum SuggestionProviderType: String {
    case mostUsedTimeEntries = "MostUsedTimeEntries"
    case randomForest = "RandomForest"
    case calendar = "Calendar"
}
