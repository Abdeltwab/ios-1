import UIKit
import Architecture
import OtherServices

public final class CalendarDayCoordinator: BaseCoordinator {
    private var store: Store<CalendarDayState, CalendarDayAction>
    private var time: Time

    public init(store: Store<CalendarDayState, CalendarDayAction>, time: Time) {
        self.store = store
        self.time = time
    }

    public override func start() {
        let viewController = CalendarDayViewController.instantiate()
        viewController.store = store
        viewController.time = time
        self.rootViewController = viewController
    }
}
