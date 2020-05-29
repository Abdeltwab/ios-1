import UIKit
import Architecture

public final class ContextualMenuCoordinator: BaseCoordinator {
    private var store: Store<ContextualMenuState, ContextualMenuAction>

    public init(store: Store<ContextualMenuState, ContextualMenuAction>) {
        self.store = store
    }

    public override func start() {
        let viewController = ContextualMenuViewController.instantiate()
        viewController.store = store
        self.rootViewController = viewController
    }
}
