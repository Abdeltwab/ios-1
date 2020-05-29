import Foundation
import Models
import Utils
import Timer

public struct CalendarDayState: Equatable {
    var selectedItem: Either<EditableTimeEntry, String>?
}
