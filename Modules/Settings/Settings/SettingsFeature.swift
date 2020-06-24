import Foundation
import Architecture
import OtherServices

public class SettingsFeature: BaseFeature<SettingsState, SettingsAction> {

    private enum Features: Hashable {
    }

    private let time: Time
    private let features: [Features: BaseFeature<SettingsState, SettingsAction>]

    public init(time: Time) {
        self.time = time

        features = [:]
    }

    public override func mainCoordinator(store: Store<SettingsState, SettingsAction>) -> Coordinator {
        return SettingsCoordinator(store: store)
    }
}
