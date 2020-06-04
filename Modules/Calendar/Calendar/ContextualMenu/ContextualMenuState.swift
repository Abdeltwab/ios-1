import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct ContextualMenuState: Equatable {
    var user: Loadable<User>
    var selectedItem: Either<EditableTimeEntry, CalendarEvent>?
    var editableTimeEntry: EditableTimeEntry?
    var timeEntries: [Int64: TimeEntry]
}
