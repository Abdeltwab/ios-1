import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

// swiftlint:disable cyclomatic_complexity
func createProjectReducer(repository: TimeLogRepository) -> Reducer<ProjectState, ProjectAction> {
    return Reducer { state, action in

        switch action {
        case .nameEntered(let name):
            state.editableProject?.name = name
            state.editableProject?.hasError = false
            return []

        case .doneButtonTapped:
            guard let editableProject = state.editableProject else { return [] }
            guard isValid(project: editableProject, existing: state.projects) else {
                state.editableProject?.hasError = true
                return []
            }
            return [createProjectEffect(state, repository)]

        case .projectCreated(let newProject):
            state.projects[newProject.id] = newProject
            state.editableProject = nil
            return []
        case .privateProjectSwitchTapped:
            state.editableProject?.isPrivate.toggle()
            return []
        case .dialogDismissed, .closeButtonTapped:
            state.editableProject = nil
            return []
        case .workspacePicked(let workspace):
            guard state.editableProject != nil else { fatalError() }
            state.editableProject?.workspaceId = workspace.id
            return []
        case .clientPicked(let client):
            guard state.editableProject != nil else { fatalError() }
            guard client.workspaceId == state.editableProject?.workspaceId else { fatalError() }
            state.editableProject?.clientId = client.id
            return []
        case .colorPicked(let color):
            guard state.editableProject != nil else { fatalError() }
            state.editableProject?.color = color
            return []
        }
    }
}

func createProjectEffect(_ state: ProjectState, _ repository: TimeLogRepository) -> Effect<ProjectAction> {
    let editableProject = state.editableProject!
    let dto = ProjectDTO(name: editableProject.name, workspaceId: editableProject.workspaceId)
    return repository.createProject(dto)
        .map(ProjectAction.projectCreated)
        .toEffect()
}

func isValid(project newProject: EditableProject, existing projects: [Int64: Project]) -> Bool {
    return projects.values.none { project in
        project.name == newProject.name &&
            project.workspaceId == newProject.workspaceId &&
            project.clientId == newProject.clientId
    }
}
