import Foundation
import Architecture

public func createCalendarReducer() -> Reducer<CalendarState, CalendarAction> {
    return Reducer { state, action in

        switch action {
        case .dummyAction:
            state = CalendarState()
            return []
        }
    }
}
