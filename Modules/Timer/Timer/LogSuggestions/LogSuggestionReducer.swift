import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices
import CalendarService

func createLogSuggestionReducer(time: Time) -> Reducer<LogSuggestionState, LogSuggestionAction> {

    // swiftlint:disable line_length
    return Reducer {state, action -> [Effect<LogSuggestionAction>] in

        switch action {

        case .loadSuggestions:
            guard case let Loadable.loaded(user) = state.user else { return [] }

            let providers: [SuggestionPrivider] = [
                CalendarSuggestionProvider(time: time, calendarEvents: Array(state.calendarEvents.values), defaultWorkspaceId: user.defaultWorkspace),
                MostUsedTimeEntrySuggestionProvider(time: time, timeLogEntities: state.entities, maxNumberOfSuggestions: TimerConstants.LogSuggestions.maxSuggestionsCount)]
            let suggestions = providers
                .map { $0.getSuggestions() }
                .flatMap { $0 }
                .take(TimerConstants.LogSuggestions.maxSuggestionsCount)
            state.logSuggestions = suggestions
            return []

        case .suggestionTapped(let suggestion):
            return [Effect.from(action: .timeEntries(.startTimeEntry(suggestion.properties.toStartTimeEntryDto())))]

        case .timeEntries:
            return []

        }
    }
    // swiftlint:enable line_length
}
