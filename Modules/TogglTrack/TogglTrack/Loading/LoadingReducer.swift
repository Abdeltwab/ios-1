import Foundation
import RxSwift
import Architecture
import Repository
import Models

func createLoadingReducer(repository: Repository) -> Reducer<LoadingState, LoadingAction> {
    return Reducer { state, action in
        switch action {

        case .startLoading:
            return loadEntities(repository)

        case .loadingFinished:
            state.route = AppRoute.main.path
            return []

        case let .workspacesLoaded(workspaces):
            state.entities.workspaces = EntityCollection(workspaces)
            return []

        case let .clientsLoaded(clients):
            state.entities.clients = EntityCollection(clients)
            return []

        case let .projectsLoaded(projects):
            state.entities.projects = EntityCollection(projects)
            return []

        case let .tasksLoaded(tasks):
            state.entities.tasks = EntityCollection(tasks)
            return []

        case let .timeEntriesLoaded(timeEntries):
            state.entities.timeEntries = EntityCollection(timeEntries)
            return []

        case let .tagsLoaded(tags):
            state.entities.tags = EntityCollection(tags)
            return []

        }
    }
}

private func loadEntities(_ repository: Repository) -> [Effect<LoadingAction>] {
    return [
        repository.getWorkspaces().map(LoadingAction.workspacesLoaded),
        repository.getClients().map(LoadingAction.clientsLoaded),
        repository.getTimeEntries().map(LoadingAction.timeEntriesLoaded),
        repository.getProjects().map(LoadingAction.projectsLoaded),
        repository.getTasks().map(LoadingAction.tasksLoaded),
        repository.getTags().map(LoadingAction.tagsLoaded),
        Single.just(LoadingAction.loadingFinished)
    ]
        .map { $0.toEffect() }
}
