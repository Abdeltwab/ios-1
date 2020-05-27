import Foundation

public enum CalendarAction: Equatable {
    case calendarDay(CalendarDayAction)
}

extension CalendarAction {
    var calendarDay: CalendarDayAction? {
        get {
            guard case let .calendarDay(value) = self else { return nil }
            return value
        }
        set {
            guard case .calendarDay = self, let newValue = newValue else { return }
            self = .calendarDay(newValue)
        }
    }
}

extension CalendarAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .calendarDay(action):
            return action.debugDescription
        }
    }
}
