import Foundation
import Models
import Utils
import CalendarService

public struct LogSuggestionState {
    var logSuggestions: [LogSuggestion]
    var entities: TimeLogEntities
    var calendarEvents: [String: CalendarEvent]
}
