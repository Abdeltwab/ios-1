import Foundation
import Models

public enum ProjectAction: Equatable {
    case nameEntered(String)
    case privateProjectSwitchTapped
    case doneButtonTapped
    case dialogDismissed
    case closeButtonTapped
    case workspacePicked(Workspace)
    case clientPicked(Client)
    case colorPicked(String)
    
    case projectCreated(Project)
    
}

extension ProjectAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case let .nameEntered(name):
            return "NameEntered \(name)"
        case .privateProjectSwitchTapped:
            return "PrivateProjectSwitchTapped"
        case .doneButtonTapped:
            return "DoneButtonTapped"
        case .projectCreated(let project):
            return "ProjectCreated \(project)"
        case .dialogDismissed:
            return "DialogDismissed"
        case .closeButtonTapped:
            return "Close button tapped"
        case .workspacePicked(let workspace):
            return "Picked workspace with id \(workspace.id)"
        case .clientPicked(let client):
            return "Picked client with id \(client.id)"
        case .colorPicked(let color):
            return "Picked color with hex \(color)"
        }
    }
}
