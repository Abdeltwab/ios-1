import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

func createCalendarDayReducer() -> Reducer<CalendarDayState, CalendarDayAction> {
    return Reducer {state, action -> [Effect<CalendarDayAction>] in

        switch action {

        case .startTimeDragged(let date):
            guard case var .left(editableTimeEntry) = state.selectedItem else {
                return []
            }
            editableTimeEntry.start = date
            return []
        }
    }
}
