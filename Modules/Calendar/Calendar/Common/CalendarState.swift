import Foundation
import Models
import Utils
import Timer

public struct LocalCalendarState: Equatable {
    internal var selectedItem: Either<EditableTimeEntry, String>?

    public init() {
    }
}

public struct CalendarState {
    public var localCalendarState: LocalCalendarState

    public init(localCalendarState: LocalCalendarState) {
        self.localCalendarState = localCalendarState
    }
}

extension CalendarState {
    internal var calendarDayState: CalendarDayState {
        get {
            CalendarDayState(
                selectedItem: localCalendarState.selectedItem
            )
        }
        set {
            localCalendarState.selectedItem = newValue.selectedItem
        }
    }
}
