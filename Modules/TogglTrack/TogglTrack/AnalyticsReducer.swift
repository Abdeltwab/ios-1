import Foundation
import Architecture
import Analytics
import Timer

func createAnalyticsReducer(analyticsService: AnalyticsService) -> (_ reducer: Reducer<AppState, AppAction>) -> Reducer<AppState, AppAction> {
    return { reducer in
        return Reducer { state, action in
            if let event = action.toEvent(state) {
                analyticsService.track(event: event)
            }
            return reducer.reduce(&state, action)
        }
    }

}

extension AppAction {
    public func toEvent(_ state: AppState) -> Event? {
        switch self {
        case let .timer(.startEdit(startEditAction)):
            return startEditAction.toEvent(state)
        case let .timer(.runningTimeEntry(runningAction)):
            return runningAction.toEvent()
        case let .timer(.timeLog(logAction)):
            return logAction.toEvent()
        default:
            return nil
        }
    }
}

extension StartEditAction {
    public func toEvent(_ state: AppState) -> Event? {
        switch self {
        case .closeButtonTapped, .dialogDismissed:
            return .editViewClosed(.close)
        case .doneButtonTapped:
            return .editViewClosed(
                state.timerState.isEditingGroup() ? .groupSave : .save
            )
        default:
            return nil
        }
    }
}

extension RunningTimeEntryAction {
    public func toEvent() -> Event? {
        switch self {
        case .stopButtonTapped:
            return .timeEntryStopped(.manual)
        case .cardTapped:
            return .editViewOpened(.runnintTimeEntryCard)
        default:
            return nil
        }
    }
}

extension TimeEntriesLogAction {
    public func toEvent() -> Event? {
        switch self {
        case .timeEntryTapped:
            return .editViewOpened(.singleTimeEntry)
        case .timeEntryGroupTapped:
            return .editViewOpened(.groupHeader)
        case let .timeEntrySwiped(direction, _) where direction == .right:
            return .timeEntryDeleted(.logSwipe)
        case let .timeEntryGroupSwiped(direction, _) where direction == .right:
            return .timeEntryDeleted(.groupedLogSwipe)
        case .undoButtonTapped:
            return .undoTapped()
        default:
            return nil
        }
    }
}
