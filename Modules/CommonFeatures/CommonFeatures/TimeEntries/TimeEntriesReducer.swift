import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

// swiftlint:disable cyclomatic_complexity
public func createTimeEntriesReducer(time: Time, repository: TimeLogRepository) -> Reducer<TimeEntriesState, TimeEntriesAction> {
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
// swiftlint:enable cyclomatic_complexity