import Foundation
import RxSwift

public protocol CalendarService {
    func getAvailableCalendars() -> Single<[CalendarSource]>
    func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [CalendarSource]) -> Single<[CalendarEvent]>
}

public class DefaultCalendarService: CalendarService {

    public init() {}

    public func getAvailableCalendars() -> Single<[CalendarSource]> {
        return Single.just([])
    }

    public func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [CalendarSource]) -> Single<[CalendarEvent]> {
        return Single.just([])
    }
}
