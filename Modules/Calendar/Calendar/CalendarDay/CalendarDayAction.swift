import Foundation
import Models

public enum CalendarDayAction: Equatable {
    case startTimeDragged(Date)
    case stopTimeDragged(Date)
    case timeEntryDragged(Date)
    case emptyPositionLongPressed(Date)
}

extension CalendarDayAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .startTimeDragged(let date):
            return "StartTimeDragged: \(date)"

        case .stopTimeDragged(let date):
            return "StopTimeDragged: \(date)"

        case .timeEntryDragged(let date):
            return "TimeEntryDragged: \(date)"

        case .emptyPositionLongPressed(let date):
            return "EmptyPositionLongPressed: \(date)"
        }
    }
}
