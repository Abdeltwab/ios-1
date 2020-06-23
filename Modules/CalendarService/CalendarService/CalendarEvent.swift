import Foundation

public struct CalendarEvent: Equatable {
    public let id: String
    public let calendarId: String
    public let calendarName: String
    public let description: String
    public let start: Date
    public let stop: Date
    public let color: String

    public init(
        id: String,
        calendarId: String,
        calendarName: String,
        description: String,
        start: Date,
        stop: Date,
        color: String
    ) {
        self.id = id
        self.calendarId = calendarId
        self.calendarName = calendarName
        self.description = description
        self.start = start
        self.stop = stop
        self.color = color
    }
}

public extension CalendarEvent {
    var duration: TimeInterval { stop.timeIntervalSince(start) }
}
