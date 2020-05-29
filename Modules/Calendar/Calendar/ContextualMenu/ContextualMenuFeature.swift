import Foundation
import Architecture

class ContextualMenuFeature: BaseFeature<ContextualMenuState, ContextualMenuAction> {
    override func mainCoordinator(store: Store<ContextualMenuState, ContextualMenuAction>) -> Coordinator {
        return ContextualMenuCoordinator(store: store)
    }
}
