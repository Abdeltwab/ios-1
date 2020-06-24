import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
func createTimeEntriesLogReducer(
    repository: TimeLogRepository,
    time: Time,
    schedulerProvider: SchedulerProvider
) -> Reducer<TimeEntriesLogState, TimeEntriesLogAction> {
    return Reducer { state, action in
        switch action {

        case let .continueButtonTapped(timeEntryId):
            return [
                Effect.from(action: .timeEntries(.continueTimeEntry(timeEntryId)))
            ]

        case let .timeEntrySwiped(direction, timeEntryId):
            switch direction {
            case .left:
                return deleteWithUndo(timeEntryIds: [timeEntryId], state: &state, repository: repository, schedulerProvider: schedulerProvider)
            case .right:
                return [
                    Effect.from(action: .timeEntries(.continueTimeEntry(timeEntryId)))
                ]
            }

        case let .timeEntryTapped(timeEntryId):
            state.editableTimeEntry = EditableTimeEntry.fromSingle(state.entities.timeEntries[id: timeEntryId]!)
            return []

        case let .timeEntryGroupTapped(timeEntryIds):
            state.editableTimeEntry = EditableTimeEntry.fromGroup(
                ids: timeEntryIds,
                groupSample: state.entities.timeEntries[id: timeEntryIds.first!]!
            )
            return []

        case let .toggleTimeEntryGroupTapped(groupId):
            if state.expandedGroups.contains(groupId) {
                 state.expandedGroups.remove(groupId)
             } else {
                 state.expandedGroups.insert(groupId)
             }
             return []

        case let .timeEntryGroupSwiped(direction, timeEntryIds):
            switch direction {
            case .left:
                return deleteWithUndo(timeEntryIds: Set(timeEntryIds), state: &state, repository: repository, schedulerProvider: schedulerProvider)
            case .right:
                return [
                    Effect.from(action: .timeEntries(.continueTimeEntry(timeEntryIds.first!)))
                ]
            }

        case let .setError(error):
            fatalError(error.description)

        case let .commitDeletion(timeEntryIds):
            let timeEntryIdsToDelete = state.entriesPendingDeletion == timeEntryIds
                ? timeEntryIds
                : []

            guard !timeEntryIdsToDelete.isEmpty else { return [] }

            state.entriesPendingDeletion.removeAll()
            return timeEntryIdsToDelete.sorted().map {
                Effect.from(action: .timeEntries(.deleteTimeEntry($0)))
            }
            
        case .undoButtonTapped:
            state.entriesPendingDeletion.removeAll()
            return []
            
        case let .logSuggestions(.suggestionTapped(suggestion)):
            return [Effect.from(action: .timeEntries(.startTimeEntry(suggestion.properties.toStartTimeEntryDto())))]
            
        case .timeEntries, .logSuggestions:
            return []
        }
    }
}

private func deleteWithUndo(
    timeEntryIds: Set<Int64>,
    state: inout TimeEntriesLogState,
    repository: TimeLogRepository,
    schedulerProvider: SchedulerProvider
) -> [Effect<TimeEntriesLogAction>] {
    let timeEntryIdsSet = timeEntryIds
    if state.entriesPendingDeletion.isEmpty {
        state.entriesPendingDeletion = timeEntryIdsSet
        return [waitForUndoEffect(timeEntryIdsSet, schedulerProvider: schedulerProvider)]
    } else {
        let teIdsToDeleteImmediately = state.entriesPendingDeletion
        state.entriesPendingDeletion = timeEntryIdsSet
        var actions: [Effect<TimeEntriesLogAction>] = teIdsToDeleteImmediately.map {
            .from(action: .timeEntries(.deleteTimeEntry($0)))
        }
        actions.append(waitForUndoEffect(timeEntryIdsSet, schedulerProvider: schedulerProvider))
        return actions
    }
}

private func waitForUndoEffect(_ entriesToDelete: Set<Int64>, schedulerProvider: SchedulerProvider) -> Effect<TimeEntriesLogAction> {
    return Observable.just(TimeEntriesLogAction.commitDeletion(entriesToDelete))
        .delay(RxTimeInterval.seconds(TimerConstants.timeEntryDeletionDelaySeconds), scheduler: schedulerProvider.mainScheduler)
        .toEffect()
}
