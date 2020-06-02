import CalendarService
import Foundation
import Models
import Utils
import Timer

public struct ContextualMenuState: Equatable {
    var selectedItem: Either<EditableTimeEntry, String>?
    var timeEntries: [Int64: TimeEntry]
}
