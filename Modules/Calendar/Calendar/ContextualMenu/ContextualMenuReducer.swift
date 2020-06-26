import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices
import Timer

// swiftlint:disable cyclomatic_complexity function_body_length
func createContextualMenuReducer() -> Reducer<ContextualMenuState, ContextualMenuAction> {
    return Reducer {state, action -> [Effect<ContextualMenuAction>] in

        switch action {

        case .cancelButtonTapped, .discardButtonTapped:
            state.selectedItem = nil
            return []

        case .saveButtonTapped:
            guard case .left(let editableTimeEntry) = state.selectedItem else { fatalError("Only time entries can be saved") }
            state.selectedItem = nil
            if editableTimeEntry.ids.isEmpty {
                return crateTimeEntryEffect(for: editableTimeEntry)
            } else {
                return updateTimeEntryEffect(for: editableTimeEntry, in: state.entities.timeEntries)
            }

        case .editButtonTapped:
            guard case .left(let editableTimeEntry) = state.selectedItem else { return [] }
            state.selectedItem = nil
            state.editableTimeEntry = editableTimeEntry
            return []

        case .stopButtonTapped:
            state.selectedItem = nil
            return [Effect.from(action: .timeEntries(.stopRunningTimeEntry))]

        case .deleteButtonTapped:
            guard case .left(let editableTimeEntry) = state.selectedItem else { fatalError("Only time entries can be continued") }
            guard let timeEntryId = editableTimeEntry.ids.first else { fatalError("Only existing time entries can be continued") }
            state.selectedItem = nil
            return [Effect.from(action: .timeEntries(.deleteTimeEntry(timeEntryId)))]

        case .continueButtonTapped:
            guard case .left(let editableTimeEntry) = state.selectedItem else { fatalError("Only time entries can be continued") }
            guard let timeEntryId = editableTimeEntry.ids.first else { fatalError("Only existing time entries can be continued") }
            state.selectedItem = nil
            return [Effect.from(action: .timeEntries(.continueTimeEntry(timeEntryId)))]

        case .startFromEventButtonTapped:
            guard case .right(let calendarEvent) = state.selectedItem else { fatalError("Selected item is not a calendar event") }
            guard case .loaded(let user) = state.user else { fatalError("Cannot get workspace id from user") }
            let dto = calendarEvent.toStartTimeEntryDto(workspaceId: user.defaultWorkspace)
            state.selectedItem = nil
            return [Effect.from(action: .timeEntries(.startTimeEntry(dto)))]

        case .copyAsTimeEntryButtonTapped:
            guard case .right(let calendarEvent) = state.selectedItem else { fatalError("Selected item is not a calendar event") }
            guard case .loaded(let user) = state.user else { fatalError("Cannot get workspace id from user") }
            let dto = calendarEvent.toCreateTimeEntryDto(workspaceId: user.defaultWorkspace)
            state.selectedItem = nil
            return [Effect.from(action: .timeEntries(.createTimeEntry(dto)))]

        case .timeEntries:
            return []
        }
    }
}
// swiftlint:enable cyclomatic_complexity function_body_length

func crateTimeEntryEffect(for editableTimeEntry: EditableTimeEntry) -> [Effect<ContextualMenuAction>] {
    return [
        Effect.from(action: .timeEntries(.createTimeEntry(editableTimeEntry.toCreateTimeEntryDto())))
    ]
}

func updateTimeEntryEffect(for editableTimeEntry: EditableTimeEntry,
                           in timeEntries: EntityCollection<TimeEntry>) -> [Effect<ContextualMenuAction>] {
    guard let timeEntry = timeEntries[id: editableTimeEntry.ids[0]] else {
        fatalError("Didn't find a TE corresponding to the edited one")
    }
    let updatedTimeEntry = timeEntry.with(
        description: editableTimeEntry.description,
        start: editableTimeEntry.start,
        duration: editableTimeEntry.duration,
        projectId: editableTimeEntry.projectId,
        taskId: editableTimeEntry.taskId,
        tagIds: editableTimeEntry.tagIds,
        billable: editableTimeEntry.billable)
    return [
        Effect.from(action: .timeEntries(.updateTimeEntry(updatedTimeEntry)))
    ]
}
