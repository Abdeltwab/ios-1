import RxSwift

#if DEBUG
public class MockCalendarService: CalendarService {

    public var availableCalendars: [CalendarSource]
    public var calendarEvents: [CalendarEvent]

    public init(availableCalendars: [CalendarSource] = [], calendarEvents: [CalendarEvent] = []) {
        self.calendarEvents = calendarEvents
        self.availableCalendars = availableCalendars
    }

    public func getAvailableCalendars() -> Single<[CalendarSource]> {
        return Single.just(availableCalendars)
    }

    public func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [CalendarSource]) -> Single<[CalendarEvent]> {
        return Single.just(calendarEvents.filter { $0.start >= start && $0.start <= endDate })
    }
}
#endif
