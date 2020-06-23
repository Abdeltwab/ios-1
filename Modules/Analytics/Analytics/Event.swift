import Foundation
import Utils

public struct Event {
    public let name: String
    public let parameters: [String: Any]?
    
    private init(_ name: String, parameters: [String: Any]? = nil) {
        self.name = name
        self.parameters = parameters
    }
    
    public static func editViewClosed(_ reason: EditViewCloseReason) -> Event {
        return Event("EditViewClosed", parameters: ["Reason": reason.rawValue.capitalized])
    }
    
    public static func editViewOpened(_ reason: EditViewOpenReason) -> Event {
        //The parameter is named "Origin" and not "Reason" for legacy reasons
        return Event("EditViewOpened", parameters: ["Origin": reason.rawValue.capitalized])
    }
    
    public static func timeEntryStopped(_ origin: TimeEntryStopOrigin) -> Event {
        return Event("TimeEntryStopped", parameters: ["Origin": origin.rawValue.capitalized])
    }
    
    public static func timeEntryDeleted(_ origin: TimeEntryDeleteOrigin) -> Event {
        //The parameter is named "Source" and not "Origin" for legacy reasons
        return Event("DeleteTimeEntry", parameters: ["Source": origin.rawValue.capitalized])
    }
    
    public static func undoTapped() -> Event {
        return Event("TimeEntryDeletionUndone", parameters: [:])
    }

    public static func suggestionsPresented(suggestionsCount: Int,
                                            calendarSuggestionProviderState: CalendarSuggestionProviderState,
                                            workspaceCount: Int,
                                            providersCount: [String: String]) -> Event {
        var params = [
            "SuggestionsCount": "\(suggestionsCount)",
            "CalendarProviderState": calendarSuggestionProviderState.rawValue,
            "DistinctWorkspaceCount": "\(workspaceCount)"
        ]

        params = params.merging(providersCount) { $1 }

        return Event("SuggestionsPresented", parameters: params)
    }

    public static func suggestionStarted(providerType: SuggestionProviderType) -> Event {
        Event("SuggestionStarted", parameters: ["SuggestionProvider": providerType.rawValue])
    }

    public static func calendarSuggestionContinueEvent(duration: TimeInterval) -> Event {
        let direction = duration < 0 ? "before" : "after"
        var text = ""
        switch Int(abs(duration)) {
        case 0..<(5 * .secondsInAMinute):
            text = "<5"
        case 0..<(15 * .secondsInAMinute):
            text = "5-15"
        case 0..<(30 * .secondsInAMinute):
            text = "15-30"
        case 0..<(60 * .secondsInAMinute):
            text = "30-60"
        default:
            text = ">60"
        }

        return Event("CalendarSuggestionContinued", parameters: ["Offset": "\(text) \(direction)"])
    }
}
