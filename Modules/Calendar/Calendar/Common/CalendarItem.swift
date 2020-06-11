import Models
import CalendarService
import RxDataSources
import Utils
import Timer

public struct CalendarItem: Equatable {
    enum Value: Equatable {
        case timeEntry(TimeEntry)
        case selectedItem(Either<EditableTimeEntry, CalendarEvent>)
        case calendarEvent(CalendarEvent)

        var description: String {
            switch self {
            case .timeEntry(let timeEntry):
                return timeEntry.description
            case .selectedItem(let selectedItem):
                switch selectedItem {
                case let .left(editableTimeEntry):
                    return editableTimeEntry.description
                case let .right(calendarEvent):
                    return calendarEvent.description
                }
            case .calendarEvent(let calendarEvent):
                return calendarEvent.description
            }
        }

        var color: String {
            switch self {
            case .timeEntry:
                return "#000000"
            case .selectedItem(let selectedItem):
                switch selectedItem {
                case let .left:
                    return "#000000"
                case let .right(calendarEvent):
                    return calendarEvent.color
                }
            case .calendarEvent(let calendarEvent):
                return calendarEvent.color
            }
        }
        var start: Date {
            switch self {
            case .timeEntry(let timeEntry):
                return timeEntry.start
            case .selectedItem(let selectedItem):
                switch selectedItem {
                case let .left(editableTimeEntry):
                    return editableTimeEntry.start!
                case let .right(calendarEvent):
                    return calendarEvent.start
                }
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
            case .selectedItem(let selectedItem):
                switch selectedItem {
                case let .left(editableTimeEntry):
                    return editableTimeEntry.duration
                case let .right(calendarEvent):
                    return calendarEvent.duration
                }
            case .calendarEvent(let calendarEvent):
                return calendarEvent.duration
            }
        }
    }

    let value: Value
    let columnIndex: Int
    let totalColumns: Int

    var description: String { value.description }
    var color: String { value.color }
    var start: Date { value.start }
    var duration: TimeInterval
    var stop: Date { start + duration }
}

extension CalendarItem: IdentifiableType {

    public typealias Identity = AnyHashable

    public var identity: Identity {
        switch self.value {
        case .timeEntry(let timeEntry): return timeEntry.id
        case .selectedItem: return "SelectedItem"
        case .calendarEvent(let calendarEvent): return calendarEvent.id
        }
    }
}
