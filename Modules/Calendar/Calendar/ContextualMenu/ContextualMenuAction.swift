import Foundation
import Models

public enum ContextualMenuAction: Equatable {
    case closeButtonTapped
    case dismissButtonTapped
    case deleteButtonTapped
}

extension ContextualMenuAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .closeButtonTapped:
            return "CloseButtonTapped"
        case .dismissButtonTapped:
            return"DismissButtonTapped"
        case .deleteButtonTapped:
            return"DismissButtonTapped"
        }
    }
}
