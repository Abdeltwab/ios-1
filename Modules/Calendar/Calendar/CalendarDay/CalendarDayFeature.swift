import Foundation
import Architecture

class CalendarDayFeature: BaseFeature<CalendarDayState, CalendarDayAction> {
    override func mainCoordinator(store: Store<CalendarDayState, CalendarDayAction>) -> Coordinator {
        return CalendarDayCoordinator(store: store)
    }
}
