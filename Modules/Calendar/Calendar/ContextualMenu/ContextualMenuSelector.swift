import Models

let shouldShowContextualMenu: (ContextualMenuState) -> Bool = { state in
    return state.selectedItem != nil
}

let selectedCalendarItem: (ContextualMenuState) -> SelectedCalendarItemViewModel? = { state in
    guard let selectedItem = state.selectedItem else { return nil }
    let project = state.entities.getProject(selectedItem.left?.projectId)
    return SelectedCalendarItemViewModel(selectedItem: selectedItem, project: project)
}
