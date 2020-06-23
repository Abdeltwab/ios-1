import Models

let shouldShowContextualMenu: (ContextualMenuState) -> Bool = { state in
    return state.selectedItem != nil
}
