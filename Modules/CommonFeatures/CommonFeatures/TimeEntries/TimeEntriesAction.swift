import Foundation
import Models
import Repository

public enum TimeEntriesAction: Equatable {
    case deleteTimeEntry(Int64)
    case continueTimeEntry(Int64)
    case startTimeEntry(StartTimeEntryDto)
    case createTimeEntry(CreateTimeEntryDto)
    case updateTimeEntry(TimeEntry)
    case stopRunningTimeEntry
    case timeEntryDeleted(Int64)
    case timeEntryUpdated(TimeEntry)
    case timeEntryStarted(started: TimeEntry, stopped: TimeEntry?)
    case timeEntryCreated(TimeEntry)
    case setError(ErrorType)
}

extension TimeEntriesAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case let .deleteTimeEntry(id):
            return "DeleteTimeEntry: \(id)"
        case let .continueTimeEntry(id):
            return "ContinueTimeEntry: \(id)"
        case let .startTimeEntry(startTimeEntryDto):
            return "StartTimeEntry: \(startTimeEntryDto.description)"
        case let .createTimeEntry(createTimeEntryDto):
            return "CreateTimeEntry: \(createTimeEntryDto.description)"
        case let .updateTimeEntry(updatedTimeEntry):
            return "UpdateTimeEntry: \(updatedTimeEntry.description)"
        case .stopRunningTimeEntry:
            return "StopRunningTimeEntry"
        case let .timeEntryDeleted(id):
            return "TimeEntryDeleted: \(id)"
        case let . timeEntryUpdated(timeEntry):
            return "TimeEntryUpdated: \(timeEntry.description)"
        case let .timeEntryStarted(startedTimeEntry, stoppedTimeEntry):
            return "TimeEntryStarted: \(startedTimeEntry.description), stopped: \(String(describing: stoppedTimeEntry?.description))"
        case let .timeEntryCreated(timeEntry):
            return "TimeEntryCreated: \(timeEntry.id)"
        case let .setError(error):
            return "SetError: \(error)"
        }
    }
}
