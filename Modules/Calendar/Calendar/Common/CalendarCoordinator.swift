import Foundation
import Architecture

public final class CalendarCoordinator: BaseCoordinator {

    private var store: Store<CalendarState, CalendarAction>

    private let calendarDayCoordinator: CalendarDayCoordinator
    private let contextualMenuCoordinator: ContextualMenuCoordinator

    public init(
        store: Store<CalendarState, CalendarAction>,
        calendarDayCoordinator: CalendarDayCoordinator,
        contextualMenuCoordinator: ContextualMenuCoordinator) {
        self.store = store
        self.calendarDayCoordinator = calendarDayCoordinator
        self.contextualMenuCoordinator = contextualMenuCoordinator
    }

    public override func start() {
        calendarDayCoordinator.start()
        contextualMenuCoordinator.start()

        let viewController = CalendarViewController()
        viewController.store = store
        viewController.calendarDayViewController = calendarDayCoordinator.rootViewController as? CalendarDayViewController
        viewController.contextualMenuViewController = contextualMenuCoordinator.rootViewController as? ContextualMenuViewController
        self.rootViewController = viewController
    }
}
