import Foundation
import Architecture

public final class CalendarCoordinator: NavigationCoordinator {

    private var store: Store<CalendarState, CalendarAction>

    public init(store: Store<CalendarState, CalendarAction>) {
        self.store = store
    }

    public override func start() {
        let viewController = CalendarViewController.instantiate()
        viewController.store = store
        navigationController.pushViewController(viewController, animated: true)
    }
}
