import Foundation
import RxSwift

public protocol CalendarService {
    func getAvailableCalendars() -> Single<[Calendar]>
    func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [Calendar]) -> Single<[CalendarEvent]>
}

public class DefaultCalendarService: CalendarService {

    public func getAvailableCalendars() -> Single<[Calendar]> {
        return Single.just([])
    }

    public func getCalendarEvents(between start: Date, and endDate: Date, in calendars: [Calendar]) -> Single<[CalendarEvent]> {
        return Single.just([])
    }
}
