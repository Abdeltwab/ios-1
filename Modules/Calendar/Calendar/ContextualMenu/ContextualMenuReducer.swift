import Foundation
import Architecture
import Models
import RxSwift
import Repository
import Timer
import OtherServices

func createContextualMenuReducer() -> Reducer<ContextualMenuState, ContextualMenuAction> {
    return Reducer {state, action -> [Effect<ContextualMenuAction>] in

        switch action {
            
        case .closeButtonTapped, .dismissButtonTapped:
            state.selectedItem = nil
            return []
        case .deleteButtonTapped:
            guard let selectedItem = state.selectedItem else { fatalError("No selected item to delete") }
            guard let editableTimeEntry = selectedItem.left else { fatalError("Selected item has to be a time entry") }
            state.selectedItem = nil
            return deleteTimeEntryEffect(for: editableTimeEntry)
        }
    }
}

func deleteTimeEntryEffect(for timeEntry: EditableTimeEntry) -> [Effect<ContextualMenuAction>] {
    return []
}
