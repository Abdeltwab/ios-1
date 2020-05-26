import Foundation
import Models

public enum RunningTimeEntryAction: Equatable {
    case cardTapped
    case stopButtonTapped
    case startButtonTapped
    case setError(ErrorType)
    case timeEntries(TimeEntriesAction)
}

extension RunningTimeEntryAction {
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

extension RunningTimeEntryAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .cardTapped:
            return "CardTapped"
            
        case .stopButtonTapped:
            return "StopButtonTapped"

        case .startButtonTapped:
            return "StartButtonTapped"

        case let .setError(error):
            return "SetError: \(error)"

        case let .timeEntries(action):
            return action.debugDescription
        }
    }
}
