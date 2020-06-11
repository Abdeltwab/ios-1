import CalendarService
import Foundation
import Models

public enum CalendarDayAction: Equatable {
    case calendarViewAppeared
    case calendarEventsFetched([CalendarEvent])
    case startTimeDragged(TimeInterval)
    case stopTimeDragged(TimeInterval)
    case timeEntryDragged(TimeInterval)
    case emptyPositionLongPressed(TimeInterval)
    case itemTapped(CalendarItem)
}

extension CalendarDayAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .calendarViewAppeared:
            return "CalendarViewAppeared"

        case .calendarEventsFetched(let events):
            return "CalendarEventsFetched: \(events.count)"

        case .startTimeDragged(let date):
            return "StartTimeDragged: \(date)"

        case .stopTimeDragged(let date):
            return "StopTimeDragged: \(date)"

        case .timeEntryDragged(let date):
            return "TimeEntryDragged: \(date)"

        case .emptyPositionLongPressed(let date):
            return "EmptyPositionLongPressed: \(date)"

        case .itemTapped:
            return "ItemTapped"
        }
    }
}
