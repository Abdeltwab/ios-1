import Models

let expandedGroupsSelector: (TimeEntriesLogState) -> Set<Int> = { state in
    return state.expandedGroups
}

let entriesPendingDeletionSelector: (TimeEntriesLogState) -> Set<Int64> = { state in
    return state.entriesPendingDeletion
}

let timeEntryViewModelsSelector: (TimeEntriesLogState) -> [TimeEntryViewModel] = { state in
    
    return state.entities.timeEntries
        .compactMap({ timeEntry in
            guard let workspace = state.entities.getWorkspace(timeEntry.workspaceId) else {
                //fatalError("Workspace missing")
                return nil
            }
            
            let project = state.entities.getProject(timeEntry.projectId)
            
            return TimeEntryViewModel(
                timeEntry: timeEntry,
                project: project,
                client: state.entities.getClient(project?.clientId),
                task: state.entities.getTask(timeEntry.taskId),
                tags: timeEntry.tagIds.compactMap(state.entities.getTag)
            )
        })
}

let toDaysMapper: ([TimeEntryViewModel], Set<Int>, Set<Int64>) -> [DayViewModel] = { timeEntries, expandedGroups, entriesPendingDeletion in
    
    return timeEntries
        .filter({ !entriesPendingDeletion.contains($0.id) })
        .grouped(by: { $0.start.ignoreTimeComponents() })
        .map(groupTimeEntries(expandedGroups))
        .map(DayViewModel.init)
        .sorted(by: { $0.day > $1.day })
}

let groupTimeEntries: (Set<Int>) -> ([TimeEntryViewModel]) -> [TimeLogCellViewModel] = { expandedGroups in

    return { timeEntryViewModels in
        return timeEntryViewModels
            .grouped { $0.groupId }
            .flatMap { group -> [TimeLogCellViewModel] in
                let sorted = group.sorted(by: { $0.start > $1.start })
                if sorted.count == 1 {
                    return [.singleEntry(sorted.first!, inGroup: false)]
                } else {
                    guard let groupId = sorted.first?.groupId, expandedGroups.contains(groupId) else {
                        return [.groupedEntriesHeader(sorted, open: false)]
                    }
                    return [.groupedEntriesHeader(sorted, open: true)]
                        + sorted.map { .singleEntry($0, inGroup: true) }
                }
            }
            .sorted(by: { $0.start > $1.start })
    }
}

extension TimeEntry {
    var groupId: Int {
        var hasher = Hasher()
        hasher.combine(start.ignoreTimeComponents())
        hasher.combine(description)
        hasher.combine(workspaceId)
        hasher.combine(projectId)
        hasher.combine(taskId)
        hasher.combine(billable)
        hasher.combine(tagIds)
        return hasher.finalize()
    }
}
