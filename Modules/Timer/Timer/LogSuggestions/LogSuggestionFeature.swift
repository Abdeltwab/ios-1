import Foundation
import Architecture

class LogSuggestionFeature: BaseFeature<LogSuggestionState, LogSuggestionAction> {
    override func mainCoordinator(store: Store<LogSuggestionState, LogSuggestionAction>) -> Coordinator {
        return LogSuggestionCoordinator(store: store)
    }
}
