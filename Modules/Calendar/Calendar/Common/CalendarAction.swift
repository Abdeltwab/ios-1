import Foundation

public enum CalendarAction: Equatable {
    case calendarDay(CalendarDayAction)
    case contextualMenu(ContextualMenuAction)
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

    var contextualMenu: ContextualMenuAction? {
        get {
            guard case let .contextualMenu(value) = self else { return nil }
            return value
        }
        set {
            guard case .contextualMenu = self, let newValue = newValue else { return }
            self = .contextualMenu(newValue)
        }
    }
}

extension CalendarAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .calendarDay(action):
            return action.debugDescription

        case let .contextualMenu(action):
            return action.debugDescription
        }
    }
}
