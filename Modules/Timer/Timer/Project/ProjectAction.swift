import Foundation
import Models

public enum ProjectAction: Equatable {
    case nameEntered(String)
    case privateProjectSwitchTapped
    case doneButtonTapped
    case projectCreated(Project)
    case dialogDismissed
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
        }
    }
}
