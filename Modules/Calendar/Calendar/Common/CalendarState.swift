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
    public var editableTimeEntry: EditableTimeEntry?
    public var localCalendarState: LocalCalendarState
    
    public init(localCalendarState: LocalCalendarState, editableTimeEntry: EditableTimeEntry?) {
        self.localCalendarState = localCalendarState
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
                selectedItem: localCalendarState.selectedItem,
                editableTimeEntry: editableTimeEntry,
                timeEntries: timeEntries
            )
        }
        set {
            localCalendarState.selectedItem = newValue.selectedItem
            editableTimeEntry = newValue.editableTimeEntry
            timeEntries = newValue.timeEntries
        }
    }
}
