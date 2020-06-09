import UIKit
import Architecture

public final class LogSuggestionCoordinator: BaseCoordinator {
    private var store: Store<LogSuggestionState, LogSuggestionAction>

    public init(store: Store<LogSuggestionState, LogSuggestionAction>) {
        self.store = store
    }

    public override func start() {
//        let viewController = LogSuggestionViewController.instantiate()
//        viewController.store = store
//        self.rootViewController = viewController
    }
}
