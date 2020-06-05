import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct CalendarDayState: Equatable {
    var user: Loadable<User>
    var selectedDate: Date
    var timeEntries: EntityCollection<TimeEntry>
    var calendarEvents: [String: CalendarEvent]
    var selectedItem: Either<EditableTimeEntry, CalendarEvent>?
}
