import Foundation
import Models

public enum SwipeDirection {
    case left
    case right
}

public enum TimeEntriesLogAction: Equatable {
    case continueButtonTapped(Int64)
    case timeEntrySwiped(SwipeDirection, Int64)
    case timeEntryTapped(Int64)

    case timeEntryGroupTapped([Int64])
    case timeEntryGroupSwiped(SwipeDirection, [Int64])
    case toggleTimeEntryGroupTapped(Int)

    case commitDeletion(Set<Int64>)
    case undoButtonTapped

    case setError(ErrorType)

    case timeEntries(TimeEntriesAction)
}

extension TimeEntriesLogAction {
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

extension TimeEntriesLogAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case let .continueButtonTapped(timeEntryId):
            return "ContinueButtonTapped: \(timeEntryId)"

        case let .timeEntrySwiped(direction, timeEntryId):
            return "TimeEntrySwiped \(direction): \(timeEntryId)"

        case let .timeEntryTapped(timeEntryId):
            return "TimeEntryTapped: \(timeEntryId)"

        case let .toggleTimeEntryGroupTapped(groupId):
            return "ToggleTimeEntryGroupTapped: \(groupId)"

        case let .timeEntryGroupSwiped(direction, timeEntryIds):
            return "TimeEntryGroupSwiped \(direction): \(timeEntryIds)"

        case let .timeEntryGroupTapped(timeEntryIds):
            return "TimeEntryGroupTapped: \(timeEntryIds)"

        case let .setError(error):
            return "SetError: \(error)"

        case let .commitDeletion(timeEntryIds):
            return "CommitDeletion: \(timeEntryIds)"
            
        case .undoButtonTapped:
            return "UndoButtonTapped"

        case let .timeEntries(action):
            return action.debugDescription
        }
    }
}
