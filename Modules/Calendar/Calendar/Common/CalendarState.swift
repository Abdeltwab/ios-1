import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct CalendarState {
    var selectedDate: Date = Date()
    var timeEntries: [Int64: TimeEntry] = [:]
    var calendarEvents: [String: CalendarEvent] = [:]
    public var localCalendarState: LocalCalendarState
    
    public init(localCalendarState: LocalCalendarState) {
        self.localCalendarState = localCalendarState
    }
}

public struct LocalCalendarState: Equatable {
    internal var selectedItem: Either<EditableTimeEntry, String>?

    public init() {}
}

extension CalendarState {
    internal var calendarDayState: CalendarDayState {
        get {
            CalendarDayState(
                selectedDate: selectedDate,
                timeEntries: timeEntries,
                calendarEvents: calendarEvents,
                selectedItem: localCalendarState.selectedItem
            )
        }
        set {
            selectedDate = newValue.selectedDate
            timeEntries = newValue.timeEntries
            calendarEvents = newValue.calendarEvents
            localCalendarState.selectedItem = newValue.selectedItem
        }
    }
}
