import Foundation
import Utils

struct LogSuggestionViewModel: Equatable {
    var suggestion: LogSuggestion
    var suggestionProperties: SuggestionProperties {
        switch suggestion {
        case let .calendar(properties):
            return properties
        case let .mostUsed(properties):
            return properties
        }
    }
    
    var identifier: String {
        var result = suggestionProperties.description
        if suggestionProperties.hasProject {
            result += ": \(suggestionProperties.projectName)"
            if suggestionProperties.hasClient {
                result += " (\(suggestionProperties.clientName))"
            }
        }
        if suggestionProperties.hasTask {
            result += " - \(suggestionProperties.taskName)"
        }
        return result
    }
    
    var description: String {
        return suggestionProperties.description
    }
    
    var projectTaskClient: NSAttributedString {
        return projectClientTaskString(projectName: suggestionProperties.projectName,
                                       projectColor: suggestionProperties.projectColor,
                                       taskName: suggestionProperties.taskName,
                                       clientName: suggestionProperties.clientName)
    }
}
