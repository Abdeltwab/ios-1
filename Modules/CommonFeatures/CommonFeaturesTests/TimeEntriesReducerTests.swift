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
        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)
        ])

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .deleteTimeEntry(0)),
            Step(.receive, .timeEntryDeleted(0)) {
                $0.remove(id: 0)
            }
        )

        assert(mockRepository.deleteCalled, "Must call delete on repository")
    }

    func testContinuesTimeEntry() {

        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 200)
        ])

        var expectedNewTimeEntry = timeEntries[0]
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .continueTimeEntry(0)),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: nil)) {
                $0.append(expectedNewTimeEntry)
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testContinuesTimeEntryWhileOtherIsRunning() {

        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)
        ])

        var expectedNewTimeEntry = timeEntries[0]
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var expectedStoppedTimeEntry = timeEntries[1]
        expectedStoppedTimeEntry.duration = 200
        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .continueTimeEntry(0)),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: expectedStoppedTimeEntry)) {
                $0.append(expectedNewTimeEntry)
                $0[id: expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testStartsATimeEntry() {

        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 200)
        ])

        let expectedNewTimeEntry = TimeEntry.with(id: mockRepository.newTimeEntryId, start: now)

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .startTimeEntry(expectedNewTimeEntry.toStartTimeEntryDto())),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: nil)) {
                $0.append(expectedNewTimeEntry)
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func testStartsATimeEntryWhileOtherIsRunning() {

        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)
        ])

        let expectedNewTimeEntry = TimeEntry.with(id: mockRepository.newTimeEntryId, start: now)

        var expectedStoppedTimeEntry = timeEntries[1]
        expectedStoppedTimeEntry.duration = 200
        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .startTimeEntry(expectedNewTimeEntry.toStartTimeEntryDto())),
            Step(.receive, .timeEntryStarted(started: expectedNewTimeEntry, stopped: expectedStoppedTimeEntry)) {
                $0.append(expectedNewTimeEntry)
                $0[id: expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )

        assert(mockRepository.startCalled, "Must call start on repository")
    }

    func test_createTimeEntry_createsATimeEntry() {

        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 200)
        ])

        let expectedNewTimeEntry = TimeEntry.with(id: mockRepository.newTimeEntryId, start: now, duration: 10)

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .createTimeEntry(expectedNewTimeEntry.toCreateTimeEntryDto())),
            Step(.receive, .timeEntryCreated(expectedNewTimeEntry)) {
                $0.append(expectedNewTimeEntry)
            }
        )

        assert(mockRepository.createCalled, "Must call create on repository")
    }

    func testStopsRunningTimeEntry() {
        let timeEntries = TimeEntriesState([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)
        ])

        var expected = timeEntries[1]
        expected.duration = 200

        assertReducerFlow(
            initialState: timeEntries,
            reducer: reducer,
            steps:
            Step(.send, .stopRunningTimeEntry),
            Step(.receive, .timeEntryUpdated(expected)) {
                $0[id: expected.id] = expected
            }
        )
    }
}
