import Models

let timeEntriesSelector: (TimeEntriesLogState) -> [DayViewModel] = { state in
    
    return timeEntryViewModelsSelector(state.entities)
        .sorted(by: { $0.start > $1.start })
        .grouped(by: { $0.start.ignoreTimeComponents() })
        .map(DayViewModel.init)
        .sorted(by: { $0.day > $1.day })
}
