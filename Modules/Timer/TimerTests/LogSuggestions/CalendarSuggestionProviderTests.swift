import XCTest
import Models
import OtherServices
import CalendarService
@testable import Timer

class CalendarSuggestionProviderTests: XCTestCase {
    var now = Date(timeIntervalSince1970: 987654321)
    var mockTime: Time!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
    }

    func test_provider_returnsOnlyOneSuggestion() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 10)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: ""),
            CalendarEvent(id: "2",
                          calendarId: "2",
                          description: "2",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 15)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()
        XCTAssertEqual(suggestions.count, 1, "Should return 1 suggestions exactlly")
    }

    func test_provider_returnsNoSuggestionLaterThanOneHourInTheFuture() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 61)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 70)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()
        XCTAssertEqual(suggestions.count, 0, "Should return 0 suggestions exactlly")
    }

    func test_provider_returnsNoSuggestionEarlierThanOneHourInThePast() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: -61)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: -40)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()
        XCTAssertEqual(suggestions.count, 0, "Should return 0 suggestions exactlly")
    }

    func test_provider_returnsSuggestionWithDescription() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 10)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()
        XCTAssertEqual(suggestions.count, 1, "Should return 0 suggestions exactlly")
    }

    func test_provider_returnsNoSuggestionWithoutDescription() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 10)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()
        XCTAssertEqual(suggestions.count, 0, "Should return 0 suggestions exactlly")
    }

    func test_provider_returnsSuggestionSrtartingCloserToNow() {
        let calendarEvents = [
            CalendarEvent(id: "1",
                          calendarId: "1",
                          description: "1",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: 15)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: ""),
            CalendarEvent(id: "2",
                          calendarId: "2",
                          description: "2",
                          start: mockTime.now().addingTimeInterval(TimeInterval(minutes: -5)),
                          stop: mockTime.now().addingTimeInterval(TimeInterval(minutes: 20)),
                          color: "")
        ]

        let provider = CalendarSuggestionProvider(time: mockTime, calendarEvents: calendarEvents, defaultWorkspaceId: 1)
        let suggestions = provider.getSuggestions()

        guard case let LogSuggestion.calendar(properties) = suggestions.first! else { return XCTFail("The should be a suggestion") }

        XCTAssertEqual(properties.description, "2", "Should return suggestions with description \"2\"")
    }
}
