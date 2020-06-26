import UIKit
import Architecture

public final class SettingsCoordinator: BaseCoordinator {
    private var store: Store<SettingsState, SettingsAction>

    public init(store: Store<SettingsState, SettingsAction>) {
        self.store = store
    }

    public override func start() {
        let viewController = SettingsViewController.instantiate()
        viewController.store = store
        self.rootViewController = viewController
    }
}
