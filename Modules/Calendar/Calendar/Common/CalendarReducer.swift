import Foundation
import Architecture
import CommonFeatures
import Repository
import OtherServices
import Utils

public func createCalendarReducer(repository: Repository, time: Time) -> Reducer<CalendarState, CalendarAction> {

    let timeEntriesCoreReducer = createTimeEntriesReducer(time: time, repository: repository)

    return combine(
        createCalendarDayReducer()
            .pullback(state: \.calendarDayState, action: \.calendarDay),
        createContextualMenuReducer()
            .decorate(with: timeEntriesCoreReducer, state: \.timeEntries, action: \.timeEntries)
            .pullback(state: \.contextualMenuState, action: \.contextualMenu)
    )
}
