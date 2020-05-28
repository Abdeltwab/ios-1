import Foundation

public struct CalendarEvent {
    let id: String
    let calendarId: String
    let description: String
    let start: Date
    let stop: Date
    let color: String
}

public extension CalendarEvent {
    var duration: TimeInterval { stop.timeIntervalSince(start) }
}
