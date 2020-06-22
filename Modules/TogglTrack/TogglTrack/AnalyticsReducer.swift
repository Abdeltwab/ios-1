import Foundation
import Architecture
import Analytics
import Timer

func createAnalyticsReducer(analyticsService: AnalyticsService) -> (_ reducer: Reducer<AppState, AppAction>) -> Reducer<AppState, AppAction> {
    return { reducer in
        return Reducer { state, action in
            let events = action.toEvents(state)
            events.forEach { event in
                analyticsService.track(event: event)
            }
            return reducer.reduce(&state, action)
        }
    }

}

extension AppAction {
    public func toEvents(_ state: AppState) -> [Event] {
        switch self {
        case let .timer(.startEdit(startEditAction)):
            return startEditAction.toEvents(state)
        case let .timer(.runningTimeEntry(runningAction)):
            return runningAction.toEvents()
        case let .timer(.timeLog(logAction)):
            return logAction.toEvents()
        default:
            return []
        }
    }
}

extension StartEditAction {
    public func toEvents(_ state: AppState) -> [Event] {
        switch self {
        case .closeButtonTapped, .dialogDismissed:
            return [.editViewClosed(.close)]
        case .doneButtonTapped:
            return [.editViewClosed(
                state.timerState.isEditingGroup() ? .groupSave : .save
            )]
        default:
            return []
        }
    }
}

extension RunningTimeEntryAction {
    public func toEvents() -> [Event] {
        switch self {
        case .stopButtonTapped:
            return [.timeEntryStopped(.manual)]
        case .cardTapped:
            return [.editViewOpened(.runnintTimeEntryCard)]
        default:
            return []
        }
    }
}

extension TimeEntriesLogAction {
    public func toEvents() -> [Event] {
        switch self {
        case .timeEntryTapped:
            return [.editViewOpened(.singleTimeEntry)]
        case .timeEntryGroupTapped:
            return [.editViewOpened(.groupHeader)]
        case let .timeEntrySwiped(direction, _) where direction == .right:
            return [.timeEntryDeleted(.logSwipe)]
        case let .timeEntryGroupSwiped(direction, _) where direction == .right:
            return [.timeEntryDeleted(.groupedLogSwipe)]
        case .undoButtonTapped:
            return [.undoTapped()]
        default:
            return []
        }
    }
}

extension LogSuggestionAction {
    public func toEvents(_ state: AppState) -> [Event] {
        switch self {
        case .suggestionLoaded(let suggestions):
            let calendarCount = suggestions.filter {
                guard case .calendar(_) = $0 else { return false }
                return true
            }.count
            let mostUsedCount = suggestions.filter {
                guard case .mostUsed(_) = $0 else { return false }
                return true
            }.count
            let randomForestCount = 0
            let workspaceCount = state.entities.workspaces.count

            let providersCount = [
                "Calendar": "\(calendarCount)",
                "MostUsedTimeEntries": "\(mostUsedCount)",
                "RandomForest": "\(randomForestCount)"
            ]

            var calendarProviderState = CalendarSuggestionProviderState.unauthorized
            if state.calendarPermissionWasGranted {
                calendarProviderState = calendarCount > 0
                    ? .suggestionsAvailable
                    : .noEvents
            }
            return [.suggestionsPresented(
                suggestionsCount: calendarCount + mostUsedCount + randomForestCount,
                calendarSuggestionProviderState: calendarProviderState,
                workspaceCount: workspaceCount,
                providersCount: providersCount)]

        case .suggestionTapped(let suggestion):
            switch suggestion {
            case .mostUsed:
                return [.suggestionStarted(providerType: .mostUsedTimeEntries)]
            case .calendar(let properties):
                let currentTime = Date()
                let startTime = properties.startTime
                let offset = currentTime.timeIntervalSince(startTime)
                return [
                    .suggestionStarted(providerType: .calendar),
                    .calendarSuggestionContinueEvent(duration: offset)
                ]
            }
        default:
            return []
        }
    }
}
