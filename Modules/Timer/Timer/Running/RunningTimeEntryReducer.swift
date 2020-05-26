import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

func createRunningTimeEntryReducer(repository: TimeLogRepository, time: Time) -> Reducer<RunningTimeEntryState, RunningTimeEntryAction> {
    return Reducer { state, action in
        switch action {
        case .cardTapped:
            if let runningTimeEntryId = runningTimeEntryViewModelSelector(state)?.id {
                guard let runningTimeEntry = state.entities.timeEntries[runningTimeEntryId]
                else { return [] }

                state.editableTimeEntry = EditableTimeEntry.fromSingle(runningTimeEntry)
                return []
            }

            guard case let Loadable.loaded(user) = state.user else { return [] }
            state.editableTimeEntry = EditableTimeEntry.empty(workspaceId: user.defaultWorkspace)

            return []

        case .stopButtonTapped:
            guard state.entities.timeEntries.runningTimeEntry != nil else { return [] }
            return [
                Effect.from(action: .timeEntries(.stopRunningTimeEntry))
            ]

        case .startButtonTapped:
            guard state.entities.timeEntries.runningTimeEntry == nil, let workspaceId = state.user.value?.defaultWorkspace else { return [] }
            let timeEntryDto = StartTimeEntryDto.empty(workspaceId: workspaceId)
            return [
                Effect.from(action: .timeEntries(.startTimeEntry(timeEntryDto)))
            ]

        case let .setError(error):
            fatalError(error.description)

        case .timeEntries:
            return []
        }
    }
}
