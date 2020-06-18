import Foundation
import Utils
import OtherServices
import Repository
import Models
import RxSwift
import CalendarService

class CalendarSuggestionProvider: SuggestionPrivider {
    private let time: Time
    private let defaultWorkspaceId: Int64
    private let calendarEvents: [CalendarEvent]

    private let lookBackTimeSpan: TimeInterval = .secondsInAnHour
    private let lookAheadTimeSpan: TimeInterval = .secondsInAnHour

    private let maxNumberOfSuggestions: Int = 1

    init(time: Time, calendarEvents: [CalendarEvent], defaultWorkspaceId: Int64) {
        self.time = time
        self.calendarEvents = calendarEvents
        self.defaultWorkspaceId = defaultWorkspaceId
    }

    // swiftlint:disable todo
    public func getSuggestions() -> [LogSuggestion] {
        let now = time.now()
        let startRange = now - lookBackTimeSpan
        let endOfRange = now + lookAheadTimeSpan

        // TODO: get selected user calendars from UserPreffs and filter the events
        return calendarEvents
            .filter { $0.start >= startRange && $0.start <= endOfRange }
            .filter { !$0.description.isEmpty }
            .sorted { self.absOffset($0) < self.absOffset($1) }
            .take(self.maxNumberOfSuggestions)
            .map(self.toLogSuggestions)
    }
    // swiftlint:enable todo

    private func toLogSuggestions(_ entry: CalendarEvent) -> LogSuggestion {
        entry.toCalendarLogSuggestion(defaultWorkspaceId: defaultWorkspaceId)
    }

    private func absOffset(_ item: CalendarEvent) -> TimeInterval {
        let currentTime = time.now()
        let startTime = item.start
        return abs(currentTime - startTime)
    }
}
