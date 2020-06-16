import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct CalendarState {
    var selectedDate: Date = Date().ignoreTimeComponents()
    var timeEntries = EntityCollection<TimeEntry>([])
    public var calendarEvents: [String: CalendarEvent]
    public var user: Loadable<User>
    public var editableTimeEntry: EditableTimeEntry?
    public var localCalendarState: LocalCalendarState
    
    public init(user: Loadable<User>,
                localCalendarState: LocalCalendarState,
                calendarEvents: [String: CalendarEvent],
                editableTimeEntry: EditableTimeEntry?) {
        self.user = user
        self.localCalendarState = localCalendarState
        self.calendarEvents = calendarEvents
        self.editableTimeEntry = editableTimeEntry
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
                user: user,
                selectedItem: localCalendarState.selectedItem,
                editableTimeEntry: editableTimeEntry,
                timeEntries: timeEntries
            )
        }
        set {
            user = newValue.user
            localCalendarState.selectedItem = newValue.selectedItem
            editableTimeEntry = newValue.editableTimeEntry
            timeEntries = newValue.timeEntries
        }
    }
}
