import Foundation
import Architecture
import OtherServices

class CalendarDayFeature: BaseFeature<CalendarDayState, CalendarDayAction> {
    let time: Time

    init(time: Time) {
        self.time = time
    }

    override func mainCoordinator(store: Store<CalendarDayState, CalendarDayAction>) -> Coordinator {
        return CalendarDayCoordinator(store: store, time: time)
    }
}
