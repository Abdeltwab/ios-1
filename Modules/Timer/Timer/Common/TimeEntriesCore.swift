import Foundation
import Models
import Architecture
import Repository
import OtherServices

public enum TimeEntriesAction: Equatable {
    case deleteTimeEntry(Int64)
    case continueTimeEntry(Int64)
    case startTimeEntry(StartTimeEntryDto)
    case stopRunningTimeEntry
    case timeEntryDeleted(Int64)
    case timeEntryUpdated(TimeEntry)
    case timeEntryStarted(started: TimeEntry, stopped: TimeEntry?)
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
        case .stopRunningTimeEntry:
            return "StopRunningTimeEntry"
        case let .timeEntryDeleted(id):
            return "TimeEntryDeleted: \(id)"
        case let . timeEntryUpdated(timeEntry):
            return "TimeEntryUpdated: \(timeEntry.description)"
        case let .timeEntryStarted(startedTimeEntry, stoppedTimeEntry):
            return "TimeEntryStarted: \(startedTimeEntry.description), stopped: \(String(describing: stoppedTimeEntry?.description))"
        case let .setError(error):
            return "SetError: \(error)"
        }
    }
}

// swiftlint:disable cyclomatic_complexity
func createTimeEntriesReducer(time: Time, repository: TimeLogRepository) -> Reducer<[Int64: TimeEntry], TimeEntriesAction> {
    return Reducer { timeEntries, action in

        switch action {

        case let .deleteTimeEntry(timeEntryId):
            return [
                deleteTimeEntryEffect(repository, timeEntryId: timeEntryId)
            ]

        case let .continueTimeEntry(timeEntryId):
            guard let timeEntry = timeEntries[timeEntryId] else { fatalError() }
            return [
                startTimeEntryEffect(repository, timeEntry: timeEntry.toStartTimeEntryDto())
            ]

        case let .startTimeEntry(startTimeEntryDto):
            return [
                startTimeEntryEffect(repository, timeEntry: startTimeEntryDto)
            ]

        case .stopRunningTimeEntry:
            guard let runningTimeEntry = timeEntries.runningTimeEntry else { fatalError() }
            var updatedTimeEntry = runningTimeEntry
            updatedTimeEntry.duration = time.now().timeIntervalSince(runningTimeEntry.start)
            return [
                updateTimeEntryEffect(repository, timeEntry: updatedTimeEntry)
            ]

        case let .timeEntryDeleted(timeEntryId):
            timeEntries[timeEntryId] = nil
            return []

        case let .timeEntryUpdated(timeEntry):
            timeEntries[timeEntry.id] = timeEntry
            return []

        case let .timeEntryStarted(startedTimeEntry, stoppedTimeEntry):
            if let stoppedTimeEntry = stoppedTimeEntry {
                timeEntries[stoppedTimeEntry.id] = stoppedTimeEntry
            }
            timeEntries[startedTimeEntry.id] = startedTimeEntry

            return []

        case let .setError(error):
            fatalError(error.description)
        }
    }
}

func deleteTimeEntryEffect(_ repository: TimeLogRepository, timeEntryId: Int64) -> Effect<TimeEntriesAction> {
    return repository.deleteTimeEntry(timeEntryId: timeEntryId)
        .toEffect(
            map: { .timeEntryDeleted(timeEntryId) },
            catch: { .setError($0.toErrorType()) }
        )
}

func startTimeEntryEffect(_ repository: TimeLogRepository, timeEntry: StartTimeEntryDto) -> Effect<TimeEntriesAction> {
    return repository.startTimeEntry(timeEntry)
        .toEffect(
            map: { .timeEntryStarted(started: $0, stopped: $1) },
            catch: { error in .setError(error.toErrorType()) }
        )
}

func updateTimeEntryEffect(_ repository: TimeLogRepository, timeEntry: TimeEntry) -> Effect<TimeEntriesAction> {
    return repository.updateTimeEntry(timeEntry)
        .toEffect(
            map: { .timeEntryUpdated(timeEntry) },
            catch: { error in .setError(error.toErrorType()) }
        )
}
