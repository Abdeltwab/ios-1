import Models
import CalendarService

public struct CalendarItem: Equatable {
    enum Value: Equatable {
        case timeEntry(TimeEntry)
        case calendarEvent(CalendarEvent)

        var description: String {
            switch self {
            case .timeEntry(let timeEntry):
                return timeEntry.description
            case .calendarEvent(let calendarEvent):
                return calendarEvent.description
            }
        }
        
        var start: Date {
            switch self {
            case .timeEntry(let timeEntry):
                return timeEntry.start
            case .calendarEvent(let timeEntry):
                return timeEntry.start
            }
        }

        var stop: Date? {
            guard let duration = self.duration else { return nil }
            return start + duration
        }

        var duration: TimeInterval? {
            switch self {
            case .timeEntry(let timeEntry):
                return timeEntry.duration
            case .calendarEvent(let calendarEvent):
                return calendarEvent.duration
            }
        }
    }

    let value: Value
    let columnIndex: Int
    let totalColumns: Int

    var description: String { value.description }
    var start: Date { value.start }
    var duration: TimeInterval?
    var stop: Date? {
        guard let duration = duration else { return nil }
        return start + duration
    }
}
