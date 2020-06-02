import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
@testable import CommonFeatures

class TimeEntriesReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockRepository: MockTimeLogRepository!
    var mockTime: Time!
    var reducer: Reducer<TimeEntriesState, TimeEntriesAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockRepository = MockTimeLogRepository(time: mockTime)
        reducer = createTimeEntriesReducer(time: mockTime, repository: mockRepository)
    }

    func testDeletedRunningTimeEntry() {
        var timeEntries = TimeEntriesState()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .deleteTimeEntry(0)),
            Step(.receive, .timeEntryDeleted(0)) {
                $0[0] = nil
            }
        )

        assert(mockRepository.deleteCalled, "Must call delete on repository")
    }

    func testContinuesTimeEntry() {

        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 200)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .continueTimeEntry(0)),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: nil)) {
                $0[expectedNewTimeEntry.id] = expectedNewTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testContinuesTimeEntryWhileOtherIsRunning() {

        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var expectedStoppedTimeEntry = timeEntries[1]!
        expectedStoppedTimeEntry.duration = 200
        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .continueTimeEntry(0)),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: expectedStoppedTimeEntry)) {
                $0[expectedNewTimeEntry.id] = expectedNewTimeEntry
                $0[expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testStartsATimeEntry() {

        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 200)

        let expectedNewTimeEntry = TimeEntry.with(id: mockRepository.newTimeEntryId, start: now)

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .startTimeEntry(expectedNewTimeEntry.toStartTimeEntryDto())),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: nil)) {
                $0[expectedNewTimeEntry.id] = expectedNewTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testStartsATimeEntryWhileOtherIsRunning() {

        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)

        let expectedNewTimeEntry = TimeEntry.with(id: mockRepository.newTimeEntryId, start: now)

        var expectedStoppedTimeEntry = timeEntries[1]!
        expectedStoppedTimeEntry.duration = 200
        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .startTimeEntry(expectedNewTimeEntry.toStartTimeEntryDto())),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: expectedStoppedTimeEntry)) {
                $0[expectedNewTimeEntry.id] = expectedNewTimeEntry
                $0[expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testStopsRunningTimeEntry() {
        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)

        var expected = timeEntries[1]!
        expected.duration = 200

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .stopRunningTimeEntry),
            Step(.receive, .timeEntryUpdated(expected)) {
                $0[expected.id] = expected
            }
        )
    }
}
