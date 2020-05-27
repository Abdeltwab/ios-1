import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

func createCalendarDayReducer() -> Reducer<CalendarDayState, CalendarDayAction> {
    return Reducer {_, action -> [Effect<CalendarDayAction>] in

        switch action {

        case .dummy:
            return []
        }
    }
}
