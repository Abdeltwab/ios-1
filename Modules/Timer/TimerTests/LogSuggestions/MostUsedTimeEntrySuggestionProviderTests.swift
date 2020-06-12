import XCTest
import Models
import OtherServices
import RxBlocking
@testable import Timer

class MostUsedTimeEntrySuggestionProviderTests: XCTestCase {
    var now = Date(timeIntervalSince1970: 987654321)
    var mockTime: Time!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
    }

    func test_provider_returnsUpToNSuggestionsWhereNIsTheNumberUsedWhenConstructingTheProvider() {
        let numberOfSuggestions = 1...5
        var entries = TimeLogEntities()
        entries.timeEntries.append(contentsOf: [
            TimeEntry(id: 1, description: "1", start: now.addingTimeInterval(-1000), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 2, description: "1", start: now.addingTimeInterval(-950), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 3, description: "2", start: now.addingTimeInterval(-900), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 4, description: "2", start: now.addingTimeInterval(-850), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 5, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 6, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 7, description: "3", start: now.addingTimeInterval(-750), duration: 50, billable: false, workspaceId: 1)
        ])

        numberOfSuggestions.forEach { suggestionCount in
            let provider = MostUsedTimeEntrySuggestionProvider(time: mockTime, timeLogEntities: entries, maxNumberOfSuggestions: suggestionCount)
            let suggestions = provider.getSuggestions()
            if suggestionCount <= 3 {
                XCTAssertEqual(suggestions.count, suggestionCount, "Should return \(suggestionCount) suggestions exactlly")
            } else {
                XCTAssertLessThanOrEqual(suggestions.count, suggestionCount, "Should return \(suggestionCount) suggestions or less")
            }
        }
    }

    func test_provider_whenThereAreNoData_returnsEmptyArray() {
        let entries = TimeLogEntities()
        let provider = MostUsedTimeEntrySuggestionProvider(time: mockTime, timeLogEntities: entries, maxNumberOfSuggestions: 3)
        let suggestions = provider.getSuggestions()
        XCTAssert(suggestions.isEmpty, "Should return no suggestion")
    }

    func test_provider_sortsTheSuggestionsByUsage() {
        var entries = TimeLogEntities()
        entries.timeEntries.append(contentsOf: [
            TimeEntry(id: 1, description: "1", start: now.addingTimeInterval(-1000), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 2, description: "1", start: now.addingTimeInterval(-950), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 3, description: "2", start: now.addingTimeInterval(-900), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 4, description: "2", start: now.addingTimeInterval(-850), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 5, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 6, description: "2", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 7, description: "3", start: now.addingTimeInterval(-750), duration: 50, billable: false, workspaceId: 1)
        ])

        let provider = MostUsedTimeEntrySuggestionProvider(time: mockTime, timeLogEntities: entries, maxNumberOfSuggestions: 3)
        let suggestions = provider.getSuggestions()
        let suggestionDescription = suggestions.compactMap { suggestion -> String? in
            guard case let LogSuggestion.mostUsed(properties) = suggestion else { return nil }
            return properties.description
        }
        XCTAssertEqual(suggestionDescription, ["2", "1", "3"], "Should return description 2,1,3")
    }

    func test_provider_returnsOnlySuggestioWhereDescriptionAndOrProjectIsAvailable() {
        var entries = TimeLogEntities()
        entries.timeEntries.append(contentsOf: [
            TimeEntry(id: 1, description: "1", start: now.addingTimeInterval(-1000), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 2, description: "1", start: now.addingTimeInterval(-950), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 3, description: "", start: now.addingTimeInterval(-900), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 4, description: "", start: now.addingTimeInterval(-850), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 5, description: "", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 6, description: "", start: now.addingTimeInterval(-800), duration: 50, billable: false, workspaceId: 1),
            TimeEntry(id: 7, description: "", start: now.addingTimeInterval(-750), duration: 50, billable: false, workspaceId: 1, projectId: 1)
        ])

        entries.projects.append(contentsOf: [
            Project(id: 1, name: "p1", isPrivate: false, isActive: true, color: "", billable: nil, workspaceId: 1, clientId: nil)
        ])

        let provider = MostUsedTimeEntrySuggestionProvider(time: mockTime, timeLogEntities: entries, maxNumberOfSuggestions: 3)
        let suggestions = provider.getSuggestions()
        let suggestionProperties = suggestions.compactMap { suggestion -> SuggestionProperties? in
            guard case let LogSuggestion.mostUsed(properties) = suggestion else { return nil }
            return properties
        }
        XCTAssertEqual(suggestions.count, 2, "Should return 2 suggestions")
        XCTAssert(!suggestionProperties[0].description.isEmpty, "First suggestion should have a description")
        XCTAssertNil(suggestionProperties[0].projectId, "First suggestion should not have a projectId")
        XCTAssert(suggestionProperties[1].description.isEmpty, "Second suggestion should have empty description")
        XCTAssertNotNil(suggestionProperties[1].projectId, "Second suggestion should have empty description")
    }
}
