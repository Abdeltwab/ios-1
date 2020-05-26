import XCTest
import Architecture
import Models
import OtherServices
import RxBlocking
import RxTest
@testable import Timer

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class TimeEntriesLogReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockRepository: MockTimeLogRepository!
    var mockTime: Time!
    var reducer: Reducer<TimeEntriesLogState, TimeEntriesLogAction>!
    var testScheduler = TestScheduler(initialClock: 0, simulateProcessingDelay: false)

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockRepository = MockTimeLogRepository(time: mockTime)
        reducer = createTimeEntriesLogReducer(repository: mockRepository, time: mockTime, schedulerProvider: SchedulerProvider(
            mainScheduler: testScheduler, backgroundScheduler: testScheduler
        ))
    }

    func testContinueTappedHappyFlow() {

        let timeEntries = createTimeEntries(now)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .continueButtonTapped(0)),
            Step(.receive, .timeEntryStarted(expectedNewTimeEntry, nil)) {
                $0.entities.timeEntries[expectedNewTimeEntry.id] = expectedNewTimeEntry
            }
        )
    }

    func testContinueTappedStoppingPreviousFlow() {

        let timeEntries = createTimeEntries(now)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var expectedStoppedTimeEntry = timeEntries[1]!
        expectedStoppedTimeEntry.duration = 100

        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .continueButtonTapped(0)),
            Step(.receive, .timeEntryStarted(expectedNewTimeEntry, expectedStoppedTimeEntry)) {
                $0.entities.timeEntries[expectedNewTimeEntry.id] = expectedNewTimeEntry
                $0.entities.timeEntries[expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )
    }

    func testTimeEntrySwipedLeftWhenNoOtherIdIsScheduledForDeletion() {

        let swipedTimeEntryId: Int64 = 0

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            testScheduler: testScheduler,
            steps:
            Step(.send, .timeEntrySwiped(.left, swipedTimeEntryId)) {
                $0.entriesPendingDeletion = [swipedTimeEntryId]
            },
            Step(.receiveAfter(5), .commitDeletion([swipedTimeEntryId])) {
                $0.entriesPendingDeletion.removeAll()
            },
            Step(.receive, .timeEntryDeleted(swipedTimeEntryId)) {
                $0.entities.timeEntries[swipedTimeEntryId] = nil
            }
        )
    }

    func testTimeEntrySwipedLeftWhenOtherIdIsScheduledForDeletion() {

        let swipedTimeEntryId: Int64 = 0
        let waitingToBeDeletedId: Int64 = 1

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [waitingToBeDeletedId])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            testScheduler: testScheduler,
            steps:
            Step(.send, .timeEntrySwiped(.left, swipedTimeEntryId)) {
                $0.entriesPendingDeletion = [swipedTimeEntryId]
            },
            Step(.receiveAfter(5), [.timeEntryDeleted(waitingToBeDeletedId), .commitDeletion([swipedTimeEntryId])]) {
                $0.entities.timeEntries[waitingToBeDeletedId] = nil
                $0.entriesPendingDeletion.removeAll()
            },
            Step(.receive, .timeEntryDeleted(swipedTimeEntryId)) {
                $0.entities.timeEntries[swipedTimeEntryId] = nil
            }
        )
    }

    func testTimeEntrySwipedLeftGroupWhenNoOtherIdIsScheduledForDeletion() {

        let swipedTimeEntryIds: Set<Int64> = [0, 1]

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            testScheduler: testScheduler,
            steps:
            Step(.send, .timeEntryGroupSwiped(.left, Array(swipedTimeEntryIds))) {
                $0.entriesPendingDeletion = swipedTimeEntryIds
            },
            Step(.receiveAfter(5), .commitDeletion(swipedTimeEntryIds)) {
                $0.entriesPendingDeletion.removeAll()
            },
            Step(.receive, [.timeEntryDeleted(1), .timeEntryDeleted(0)]) {
                $0.entities.timeEntries[0] = nil
                $0.entities.timeEntries[1] = nil
            }
        )
    }

    func testTimeEntrySwipedLeftGroupWhenOtherIdIsScheduledForDeletion() {

        let swipedTimeEntryIds: Set<Int64> = [0, 1]
        let waitingToBeDeletedId: Int64 = 2

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [waitingToBeDeletedId])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            testScheduler: testScheduler,
            steps:
            Step(.send, .timeEntryGroupSwiped(.left, Array(swipedTimeEntryIds))) {
                $0.entriesPendingDeletion = swipedTimeEntryIds
            },
            Step(.receiveAfter(5), [.timeEntryDeleted(waitingToBeDeletedId), .commitDeletion(swipedTimeEntryIds)]) {
                $0.entities.timeEntries[waitingToBeDeletedId] = nil
                $0.entriesPendingDeletion.removeAll()
            },
            Step(.receive, [.timeEntryDeleted(0), .timeEntryDeleted(1)]) {
                $0.entities.timeEntries[0] = nil
                $0.entities.timeEntries[1] = nil
            }
        )
    }

    func testTimeEntrySwipedRightHappyFlow() {

        let swipedTimeEntryId: Int64 = 0

        let timeEntries = createTimeEntries(now)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .timeEntrySwiped(.right, swipedTimeEntryId)),
            Step(.receive, .timeEntryStarted(expectedNewTimeEntry, nil)) {
                $0.entities.timeEntries[expectedNewTimeEntry.id] = expectedNewTimeEntry
            }
        )
    }

    func testTimeEntrySwipedRightWithRunningEntry() {

        let swipedTimeEntryId: Int64 = 0

        let timeEntries = createTimeEntries(now)

        var expectedNewTimeEntry = timeEntries[0]!
        expectedNewTimeEntry.id = mockRepository.newTimeEntryId
        expectedNewTimeEntry.start = now
        expectedNewTimeEntry.duration = nil

        var expectedStoppedTimeEntry = timeEntries[1]!
        expectedStoppedTimeEntry.duration = 100

        mockRepository.stoppedTimeEntry = expectedStoppedTimeEntry

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .timeEntrySwiped(.right, swipedTimeEntryId)),
            Step(.receive, .timeEntryStarted(expectedNewTimeEntry, expectedStoppedTimeEntry)) {
                $0.entities.timeEntries[expectedNewTimeEntry.id] = expectedNewTimeEntry
                $0.entities.timeEntries[expectedStoppedTimeEntry.id] = expectedStoppedTimeEntry
            }
        )
    }

    func testTimeEntryTapped() {

        let timeEntryTappedId: Int64 = 0

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        let editableTimeEntry = EditableTimeEntry.fromSingle(timeEntries[timeEntryTappedId]!)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .timeEntryTapped(timeEntryTappedId)) {
                $0.editableTimeEntry = editableTimeEntry
            }
        )
    }

    func testTimeEntryGroupTapped() {

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [])

        let allIds = entities.timeEntries.values.map({ $0.id })
        let editableTimeEntry = EditableTimeEntry.fromGroup(ids: allIds, groupSample: timeEntries.values.first!)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .timeEntryGroupTapped(allIds)) {
                $0.editableTimeEntry = editableTimeEntry
            }
        )
    }

    func testUndoButtonTappedWhenEntriesPendingDeletionHasValues() {

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [0, 1])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .undoButtonTapped) {
                $0.entriesPendingDeletion.removeAll()
            }
        )
    }

    func testUndoButtonTappedWhenEntriesPendingDeletionHasNoValues() {

        let timeEntries = createTimeEntries(now)

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .undoButtonTapped) {
                $0.entriesPendingDeletion.removeAll()
            }
        )
    }

    func testCommitDeletionDeletesMultipleEntries() {

        let timeEntries = createTimeEntries(now)

        let entriesToBeDeleted: Set<Int64> = [0, 1]

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: entriesToBeDeleted)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps: Step(.send, .commitDeletion(entriesToBeDeleted)) {
                $0.entriesPendingDeletion = []
            },
            Step(.receive, [.timeEntryDeleted(0), .timeEntryDeleted(1)]) { (state) in
                state.entities.timeEntries[0] = nil
                state.entities.timeEntries[1] = nil
            }
        )
    }

    func testCommitDeletionDeletesSingleEntry() {

        let timeEntries = createTimeEntries(now)

        let entriesToBeDeleted: Set<Int64> = [0]

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: entriesToBeDeleted)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps: Step(.send, .commitDeletion(entriesToBeDeleted)) {
                $0.entriesPendingDeletion = []
            },
            Step(.receive, .timeEntryDeleted(0)) { (state) in
                state.entities.timeEntries[0] = nil
            }
        )
    }

    func testCommitDeletionDoesNothingWhenNoIdsProvided() {

        let timeEntries = createTimeEntries(now)

        let entriesToBeDeleted: Set<Int64> = []

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: entriesToBeDeleted)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps: Step(.send, .commitDeletion(entriesToBeDeleted))
        )
    }

    func testCommitDeletionDoesNothingWhenStateEntriesPendingDeletionIsDifferentFromIdsProvided() {

        let timeEntries = createTimeEntries(now)

        let entriesToBeDeleted: Set<Int64> = [0, 1]

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [2])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps: Step(.send, .commitDeletion(entriesToBeDeleted))
        )
    }

    func testCommitDeletionDoesNothingWhenStateEntriesPendingDeletionIsSubsetOfIdsProvided() {

        let timeEntries = createTimeEntries(now)

        let entriesToBeDeleted: Set<Int64> = [0, 1, 2]

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = TimeEntriesLogState(entities: entities, expandedGroups: [], entriesPendingDeletion: [1, 2])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps: Step(.send, .commitDeletion(entriesToBeDeleted))
        )
    }

    private func createTimeEntries(_ now: Date) -> [Int64: TimeEntry] {
        var timeEntries = [Int64: TimeEntry]()
        timeEntries[0] = TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)
        timeEntries[1] = TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 100)
        timeEntries[2] = TimeEntry.with(id: 2, start: now.addingTimeInterval(-100), duration: 100)
        return timeEntries
    }
}
