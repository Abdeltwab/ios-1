import UIKit
import Architecture

public final class CalendarDayCoordinator: BaseCoordinator {
    private var store: Store<CalendarDayState, CalendarDayAction>

    public init(store: Store<CalendarDayState, CalendarDayAction>) {
        self.store = store
    }

    public override func start() {
        let viewController = CalendarDayViewController.instantiate()
        viewController.store = store
        self.rootViewController = viewController
    }
}
