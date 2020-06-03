import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices
import Timer

func createContextualMenuReducer() -> Reducer<ContextualMenuState, ContextualMenuAction> {
    return Reducer {state, action -> [Effect<ContextualMenuAction>] in

        switch action {
            
        case .closeButtonTapped, .dismissButtonTapped:
            state.selectedItem = nil
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

        case .timeEntries:
            return []
        }
    }
}
