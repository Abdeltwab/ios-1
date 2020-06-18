import Foundation
import Models
import Utils
import CalendarService

public struct LogSuggestionState: Equatable {
    var logSuggestions: [LogSuggestion]
    var entities: TimeLogEntities
    var calendarEvents: [String: CalendarEvent]
    var user: Loadable<User>
}
