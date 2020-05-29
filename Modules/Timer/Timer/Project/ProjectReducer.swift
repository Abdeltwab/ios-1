import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

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
        case .dialogDismissed:
            state.editableProject = nil
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
