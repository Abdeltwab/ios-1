import CalendarService
import RxSwift

class MockCalendarService: CalendarService {

    let calendarEvents: [CalendarEvent]

    init(calendarEvents: [CalendarEvent]) {
        self.calendarEvents = calendarEvents
    }

    func getAvailableCalendars() -> Single<[CalendarSource]> {
        return .just([])
    }

    func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [CalendarSource]) -> Single<[CalendarEvent]> {
        return .just(calendarEvents)
    }
}
