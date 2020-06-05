import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
import RxBlocking
@testable import Timer

class RunningTimeEntryReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockRepository: MockTimeLogRepository!
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<RunningTimeEntryState, RunningTimeEntryAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockRepository = MockTimeLogRepository(time: mockTime)
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        reducer = createRunningTimeEntryReducer(repository: mockRepository, time: mockTime)
    }

    func testCardTappedWithRunningEntry() {

        let runningEntry = TimeEntry(id: 0, description: "", start: mockTime.now() - 1000, duration: nil, billable: false, workspaceId: 0, tagIds: [])

        var entities = TimeLogEntities()
        entities.timeEntries.insert(runningEntry, at: entities.timeEntries.endIndex)

        let state = RunningTimeEntryState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: nil
        )

        let expectedEditableEntry = EditableTimeEntry.fromSingle(runningEntry)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, RunningTimeEntryAction.cardTapped) {
                $0.editableTimeEntry = expectedEditableEntry
            }
        )
    }

    func testCardTappedWithoutRunningEntry() {

        let state = RunningTimeEntryState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: nil
        )

        let expectedEditableEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, RunningTimeEntryAction.cardTapped) {
                $0.editableTimeEntry = expectedEditableEntry
            }
        )
    }

    func testStopButtonTappedStopsTimeEntry() {
        let timeEntries = EntityCollection([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: nil)
        ])

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = RunningTimeEntryState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped),
            Step(.receive, .timeEntries(.stopRunningTimeEntry))
        )
    }

    func testStopButtonTappedDoesNothingIfThereIsNoRunninTE() {
        let timeEntries = EntityCollection([
            TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100),
            TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 100)
        ])

        var entities = TimeLogEntities()
        entities.timeEntries = timeEntries
        let state = RunningTimeEntryState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped))
    }

    func testStartTimeEntryTapped() {

        mockUser.defaultWorkspace = 1
        let expectedStartedEntry = TimeEntry(
            id: mockRepository.newTimeEntryId,
            description: "",
            start: mockTime.now(),
            duration: nil,
            billable: false,
            workspaceId: mockUser.defaultWorkspace,
            tagIds: []
        )

        let state = RunningTimeEntryState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .startButtonTapped),
            Step(.receive, .timeEntries(.startTimeEntry(expectedStartedEntry.toStartTimeEntryDto())))
        )
    }
}
