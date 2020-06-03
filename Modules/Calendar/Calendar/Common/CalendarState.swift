import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct CalendarState {
    var user: Loadable<User> = .nothing
    var selectedDate: Date = Date()
    var timeEntries: [Int64: TimeEntry] = [:]
    var calendarEvents: [String: CalendarEvent] = [:]
    public var localCalendarState: LocalCalendarState
    
    public init(localCalendarState: LocalCalendarState) {
        self.localCalendarState = localCalendarState
    }
}

public struct LocalCalendarState: Equatable {
    internal var selectedItem: Either<EditableTimeEntry, CalendarEvent>?

    public init() {}
}

extension CalendarState {
    internal var calendarDayState: CalendarDayState {
        get {
            CalendarDayState(
                user: user,
                selectedDate: selectedDate,
                timeEntries: timeEntries,
                calendarEvents: calendarEvents,
                selectedItem: localCalendarState.selectedItem
            )
        }
        set {
            user = newValue.user
            selectedDate = newValue.selectedDate
            timeEntries = newValue.timeEntries
            calendarEvents = newValue.calendarEvents
            localCalendarState.selectedItem = newValue.selectedItem
        }
    }

    internal var contextualMenuState: ContextualMenuState {
        get {
            ContextualMenuState(
                selectedItem: localCalendarState.selectedItem,
                timeEntries: timeEntries
            )
        }
        set {
            localCalendarState.selectedItem = newValue.selectedItem
            timeEntries = newValue.timeEntries
        }
    }
}
