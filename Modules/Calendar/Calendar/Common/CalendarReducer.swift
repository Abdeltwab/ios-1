import CalendarService
import Foundation
import Architecture
import CommonFeatures
import Repository
import OtherServices
import Utils

public func createCalendarReducer(repository: Repository, time: Time, calendarService: CalendarService) -> Reducer<CalendarState, CalendarAction> {

    let timeEntriesCoreReducer = createTimeEntriesReducer(time: time, repository: repository)

    return combine(
        createCalendarDayReducer(calendarService: calendarService)
            .pullback(state: \.calendarDayState, action: \.calendarDay),
        createContextualMenuReducer()
            .decorate(with: timeEntriesCoreReducer, state: \.entities.timeEntries, action: \.timeEntries)
            .pullback(state: \.contextualMenuState, action: \.contextualMenu)
    )
}
