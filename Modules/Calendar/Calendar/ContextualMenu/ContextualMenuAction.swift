import Foundation
import Models
import CommonFeatures

public enum ContextualMenuAction: Equatable {
    case closeButtonTapped
    case dismissButtonTapped
    case stopButtonTapped
    case deleteButtonTapped
    case continueButtonTapped

    case timeEntries(TimeEntriesAction)
}

extension ContextualMenuAction {
    var timeEntries: TimeEntriesAction? {
        get {
            guard case let .timeEntries(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeEntries = self, let newValue = newValue else { return }
            self = .timeEntries(newValue)
        }
    }
}

extension ContextualMenuAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .closeButtonTapped:
            return "CloseButtonTapped"
        case .dismissButtonTapped:
            return "DismissButtonTapped"
        case .stopButtonTapped:
            return "StopButtonTapped"
        case .deleteButtonTapped:
            return "DeleteButtonTapped"
        case .continueButtonTapped:
            return "ContinueButtonTapped"
        case .timeEntries(let action):
            return action.debugDescription
        }
    }
}
