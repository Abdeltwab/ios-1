import Foundation
import Architecture

public func createCalendarReducer() -> Reducer<CalendarState, CalendarAction> {
    return combine(
        createCalendarDayReducer()
            .pullback(state: \.calendarDayState, action: \.calendarDay)
    )
}
