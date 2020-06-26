import Foundation
import Architecture

class SettingsFeature: BaseFeature<SettingsState, SettingsAction> {
    override func mainCoordinator(store: Store<SettingsState, SettingsAction>) -> Coordinator {
        return SettingsCoordinator(store: store)
    }
}
