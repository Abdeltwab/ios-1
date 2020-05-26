import Foundation
import Models
import Utils

public struct RunningTimeEntryState: Equatable {
    var user: Loadable<User>
    var entities: TimeLogEntities
    var editableTimeEntry: EditableTimeEntry?
}
