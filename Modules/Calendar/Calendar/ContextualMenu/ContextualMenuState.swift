import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct ContextualMenuState: Equatable {
    var selectedItem: Either<EditableTimeEntry, CalendarEvent>?
    var timeEntries: [Int64: TimeEntry]
}
