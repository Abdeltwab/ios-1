import UIKit
import Architecture
import OtherServices

public final class StartEditCoordinator: BaseCoordinator {
    private var store: Store<StartEditState, StartEditAction>
    private var time: Time
        
    public init(store: Store<StartEditState, StartEditAction>, time: Time) {
        self.store = store
        self.time = time
    }
    
    public override func start() {
        let startEditViewController = StartEditViewController.instantiate()
        startEditViewController.store = store
        startEditViewController.time = time

        let sheetController = BottomSheetViewController<StartEditViewController>(viewController: startEditViewController)
      
        self.rootViewController = sheetController
    }
}
