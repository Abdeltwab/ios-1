import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
import RxBlocking
import CalendarService
@testable import Timer

class LogSuggestionReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<LogSuggestionState, LogSuggestionAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        reducer = createLogSuggestionReducer(time: mockTime)
    }
    
    // swiftlint:disable line_length
    func test_loadSuggestions_setsTheSuggestionsInTheState() {
        var entries = TimeLogEntities()
        entries.timeEntries.append(contentsOf: [
            TimeEntry(id: 1, description: "1", start: now.addingTimeInterval(-1000), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 2, description: "1", start: now.addingTimeInterval(-950), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 3, description: "2", start: now.addingTimeInterval(-900), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 4, description: "2", start: now.addingTimeInterval(-850), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 5, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 6, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace),
            TimeEntry(id: 7, description: "3", start: now.addingTimeInterval(-750), duration: 50, billable: false, workspaceId: mockUser.defaultWorkspace)
        ])

        let calendarEvents = [
            "1": CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 10)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: ""),
            "2": CalendarEvent(id: "2",
                          calendarId: "2",
                          description: "2",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 15)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: "")
        ]

        let expectedSuggestions = suggestionsFor(entries: entries, calendarEvents: calendarEvents)

        let state = LogSuggestionState(
            logSuggestions: [],
            entities: entries,
            calendarEvents: calendarEvents,
            user: Loadable.loaded(mockUser)
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, LogSuggestionAction.loadSuggestions) {
                $0.logSuggestions = expectedSuggestions
            }
        )
    }

    private func suggestionsFor(entries: TimeLogEntities, calendarEvents: [String: CalendarEvent]) -> [LogSuggestion] {
        return (
            [CalendarSuggestionProvider(time: mockTime, calendarEvents: Array(calendarEvents.values), defaultWorkspaceId: mockUser.defaultWorkspace),
            MostUsedTimeEntrySuggestionProvider(time: mockTime, timeLogEntities: entries, maxNumberOfSuggestions: TimerConstants.LogSuggestions.maxSuggestionsCount)]
                as [SuggestionPrivider])
            .map { $0.getSuggestions() }
            .flatMap { $0 }
            .take(TimerConstants.LogSuggestions.maxSuggestionsCount)
    }
    // swiftlint:enable line_length
}
