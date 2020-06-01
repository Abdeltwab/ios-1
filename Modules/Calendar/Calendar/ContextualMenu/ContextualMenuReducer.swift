import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

func createContextualMenuReducer() -> Reducer<ContextualMenuState, ContextualMenuAction> {
    return Reducer {state, action -> [Effect<ContextualMenuAction>] in

        switch action {
            
        case .closeButtonTapped, .dismissButtonTapped:
            state.selectedItem = nil
            return []
        }
    }
}
