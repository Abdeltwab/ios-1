import Foundation
import Architecture
import OtherServices

public class CalendarFeature: BaseFeature<CalendarState, CalendarAction> {

    private enum Features {
        case calendarDay
    }

    private let time: Time
    private let features: [Features: BaseFeature<CalendarState, CalendarAction>]

    public init(time: Time) {
        self.time = time

        features = [
               .calendarDay: CalendarDayFeature()
                   .view { $0.view(
                       state: { $0.calendarDayState },
                       action: { CalendarAction.calendarDay($0) })
               }
           ]
    }

    // swiftlint:disable force_cast
    public override func mainCoordinator(store: Store<CalendarState, CalendarAction>) -> Coordinator {
        return CalendarCoordinator(
            store: store,
            calendarDayCoordinator: features[.calendarDay]!.mainCoordinator(store: store) as! CalendarDayCoordinator
        )
    }
    // swiftlint:enable force_cast
}
