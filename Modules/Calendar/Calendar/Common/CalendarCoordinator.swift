import Foundation
import Architecture

public final class CalendarCoordinator: BaseCoordinator {

    private var store: Store<CalendarState, CalendarAction>

    private let calendarDayCoordinator: CalendarDayCoordinator

    public init(
        store: Store<CalendarState, CalendarAction>,
        calendarDayCoordinator: CalendarDayCoordinator) {
        self.store = store
        self.calendarDayCoordinator = calendarDayCoordinator
    }

    public override func start() {
        calendarDayCoordinator.start()

        let viewController = CalendarViewController()
        viewController.store = store
        viewController.calendarDayViewController = calendarDayCoordinator.rootViewController as? CalendarDayViewController
        self.rootViewController = viewController
    }
}
