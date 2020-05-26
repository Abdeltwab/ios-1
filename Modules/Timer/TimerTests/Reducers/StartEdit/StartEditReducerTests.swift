import XCTest
import Architecture
import Models
import OtherServices
@testable import Timer

// swiftlint:disable type_body_length
// swiftlint:disable file_length
class StartEditReducerTests: XCTestCase {
    var now = Date(timeIntervalSince1970: 987654321)
    var mockRepository: MockTimeLogRepository!
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<StartEditState, StartEditAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockRepository = MockTimeLogRepository(time: mockTime)
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)

        reducer = createStartEditReducer(repository: mockRepository, time: mockTime)
    }

    func testDescriptionEntered() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0
        )

        let expectedDescription = "whatever"

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .descriptionEntered(expectedDescription, expectedDescription.count)) {
                $0.editableTimeEntry?.description = expectedDescription
                $0.cursorPosition = expectedDescription.count
            },
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([]))
        )
    }

    func testCloseButtonTapped() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .closeButtonTapped) {
                $0.editableTimeEntry = nil
            }
        )
    }

    func testDialogDismissed() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dialogDismissed) {
                $0.editableTimeEntry = nil
            }
        )
    }

    func testDoneButtonTappedWhenTheresNoRunningEntry() {

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0
        )

        let expectedStartedEntry = TimeEntry(
            id: mockRepository.newTimeEntryId,
            description: editableTimeEntry.description,
            start: mockTime.now(),
            duration: nil,
            billable: editableTimeEntry.billable,
            workspaceId: mockUser.defaultWorkspace,
            tagIds: []
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .doneButtonTapped),
            Step(.receive, .timeEntries(.startTimeEntry(expectedStartedEntry.toStartTimeEntryDto())))
        )
    }

    func testDoneButtonTappedWhenTheresARunningEntry() {

        let runningTimeEntry = TimeEntry(
            id: 100,
            description: "Doing stuff",
            start: now.addingTimeInterval(-90),
            duration: nil,
            billable: false,
            workspaceId: mockUser.defaultWorkspace,
            tagIds: []
        )

        var entities = TimeLogEntities()
        entities.timeEntries[runningTimeEntry.id] = runningTimeEntry
        mockRepository.stoppedTimeEntry = runningTimeEntry

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0)

        let expectedStartedEntry = TimeEntry(
            id: mockRepository.newTimeEntryId,
            description: editableTimeEntry.description,
            start: mockTime.now(),
            duration: nil,
            billable: false,
            workspaceId: editableTimeEntry.workspaceId,
            tagIds: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .doneButtonTapped),
            Step(.receive, .timeEntries(.startTimeEntry(expectedStartedEntry.toStartTimeEntryDto())))
        )
    }

    func testEnteringDescriptionAndThenPressingDone() {
        let entities = TimeLogEntities()
        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0)

        let expectedStartedEntry = TimeEntry(
            id: mockRepository.newTimeEntryId,
            description: "hello",
            start: mockTime.now(),
            duration: nil,
            billable: false,
            workspaceId: editableTimeEntry.workspaceId,
            tagIds: [])

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "h"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            descriptionEnteredStep(for: "he"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            descriptionEnteredStep(for: "hel"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            descriptionEnteredStep(for: "hell"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            descriptionEnteredStep(for: "hello"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, StartEditAction.doneButtonTapped),
            Step(.receive, .timeEntries(.startTimeEntry(expectedStartedEntry.toStartTimeEntryDto())))
        )
    }

    func test_stopButtonTapped_forTEWithNoStartTime_shouldSetEditableTimeEntryStartAndDuration() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .start,
            cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped) {
                $0.editableTimeEntry?.start = self.mockTime.now()
                $0.editableTimeEntry?.duration = 0
            }
        )
    }

    func test_stopButtonTapped_forTEWithNoDuration_shouldSetEditableTimeEntryDuration() {
        let duration = TimeInterval(600)
        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = mockTime.now().addingTimeInterval(-duration)

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .start,
            cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped) { $0.editableTimeEntry?.duration = duration }
        )
    }

    func test_stopButtonTapped_forTEWithDuration_shouldOpenEndPicker() {
        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = mockTime.now()
        editableTimeEntry.duration = TimeInterval(600)

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .start,
            cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped) { $0.dateTimePickMode = .stop }
        )
    }

    func test_dateTimePicked_when_pickerMode_is_none() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let picked = Date(timeIntervalSinceReferenceDate: 100)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePicked(picked)) { _ in }
        )
    }

    func test_dateTimePicked_whenEditableTimeEntry_is_nil() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: nil,
            autocompleteSuggestions: [],
            dateTimePickMode: .start, cursorPosition: 0
        )

        let picked = Date(timeIntervalSinceReferenceDate: 100)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePicked(picked)) { _ in }
        )
    }

    func test_dateTimePicked_forStartTime_shouldUpdateStartTime() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .start, cursorPosition: 0
        )

        let start = Date(timeIntervalSinceReferenceDate: 100)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePicked(start)) { $0.editableTimeEntry?.start = start }
        )
    }

    func test_dateTimePicked_forEndTimeWithAValidStartTime_shouldUpdateDuration() {
        let start = Date(timeIntervalSinceReferenceDate: 100)
        let end = Date(timeIntervalSinceReferenceDate: 200)
        var timeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        timeEntry.start = Date(timeIntervalSinceReferenceDate: 100)

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: timeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .stop, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePicked(end)) { $0.editableTimeEntry?.duration = end.timeIntervalSince(start) }
        )
    }

    func test_dateTimePicked_forEndTimeWithNoStartTime_shouldNotUpdateDuration() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop, cursorPosition: 0
        )

        let end = Date(timeIntervalSinceReferenceDate: 200)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePicked(end)) { $0.editableTimeEntry?.duration = nil }
        )
    }

    func test_startButtonTapped_twice() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .startButtonTapped) { $0.dateTimePickMode = .start },
            Step(.send, .startButtonTapped) { $0.dateTimePickMode = .none }
        )
    }

    func test_stopButtonTapped_twice_when_duration_is_not_nil() {
        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now
        editableTimeEntry.duration = 100

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .stopButtonTapped) { $0.dateTimePickMode = .stop },
            Step(.send, .stopButtonTapped) { $0.dateTimePickMode = .none }
        )
    }

    func test_startButtonTapped_andThen_stopButtonTapped() {
        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now
        editableTimeEntry.duration = 100

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .startButtonTapped) { $0.dateTimePickMode = .start },
            Step(.send, .stopButtonTapped) { $0.dateTimePickMode = .stop }
        )
    }

    func testDateTimePikcingCancelled() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .dateTimePickingCancelled) { $0.dateTimePickMode = .none }
        )
    }

    func testAutocompleteSuggestionTappedWithATimeEntrySuggestion() {

        let oldTimeEntry = TimeEntry.with(description: "old description", billable: false)
        var newTimeEntry = TimeEntry.with(id: 10, description: "new description", billable: true)
        newTimeEntry.tagIds = [1, 2, 3]
        newTimeEntry.projectId = 11
        newTimeEntry.taskId = 12
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(oldTimeEntry),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop, cursorPosition: 0
        )

        let suggestion = AutocompleteSuggestion.timeEntrySuggestion(timeEntry: newTimeEntry)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .autocompleteSuggestionTapped(suggestion)) {
                $0.editableTimeEntry?.workspaceId = newTimeEntry.workspaceId
                $0.editableTimeEntry?.description = newTimeEntry.description
                $0.editableTimeEntry?.projectId = newTimeEntry.projectId
                $0.editableTimeEntry?.tagIds = newTimeEntry.tagIds
                $0.editableTimeEntry?.taskId = newTimeEntry.taskId
                $0.editableTimeEntry?.billable = newTimeEntry.billable
        })
    }

    func testAutocompleteSuggestionTappedWithAProjectSuggestion() {

        let timeEntry = TimeEntry.with(description: "old description @proj", billable: false)
        let project = Project.with(id: 11, name: "Project", workspaceId: 10)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(timeEntry),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop,
            cursorPosition: 19
        )

        let suggestion = AutocompleteSuggestion.projectSuggestion(project: project)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .autocompleteSuggestionTapped(suggestion)) {
                $0.editableTimeEntry?.description = "old description "
                $0.editableTimeEntry?.projectId = project.id
                $0.editableTimeEntry?.workspaceId = project.workspaceId
        })
    }

    func test_autocompleteSuggestionTapped_withATaskSuggestion() {

        let timeEntry = TimeEntry.with(description: "old description @proj", billable: false)
        let project = Project.with(id: 11, name: "Project", workspaceId: 10)
        let task = Task.with(id: 12, name: "Project", projectId: 11, workspaceId: 10)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(timeEntry),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop,
            cursorPosition: 19
        )

        let suggestion = AutocompleteSuggestion.taskSuggestion(task: task, project: project)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .autocompleteSuggestionTapped(suggestion)) {
                $0.editableTimeEntry?.description = "old description "
                $0.editableTimeEntry?.taskId = task.id
                $0.editableTimeEntry?.projectId = project.id
                $0.editableTimeEntry?.workspaceId = project.workspaceId
        })
    }

    func test_autocompleteSuggestionTapped_withATagSuggestionInAValidWorkspace() {

        let timeEntry = TimeEntry.with(description: "old description #tag", billable: false, workspaceId: 2)
        let tag = Tag(id: 11, name: "Project", workspaceId: 2)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(timeEntry),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop,
            cursorPosition: 19
        )

        let suggestion = AutocompleteSuggestion.tagSuggestion(tag: tag)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .autocompleteSuggestionTapped(suggestion)) {
                $0.editableTimeEntry?.description = "old description "
                $0.editableTimeEntry?.tagIds.append(tag.id)
        })
    }

    func test_autocompleteSuggestionTapped_withATagSuggestionInAInvalidWorkspace() {

        let timeEntry = TimeEntry.with(description: "old description #tag", billable: false)
        let tag = Tag(id: 11, name: "Project", workspaceId: 10)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(timeEntry),
            autocompleteSuggestions: [],
            dateTimePickMode: .stop,
            cursorPosition: 19
        )

        let suggestion = AutocompleteSuggestion.tagSuggestion(tag: tag)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .autocompleteSuggestionTapped(suggestion)))
    }

    func testAutocompleteSuggestionsUpdatedUpdatesState() {
        let entities = TimeLogEntities()
        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let initialState = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0)

        let autocompleteSuggestions: [AutocompleteSuggestion] = [
            .timeEntrySuggestion(timeEntry: TimeEntry.with(id: 0, start: now.addingTimeInterval(-300), duration: 100)),
            .timeEntrySuggestion(timeEntry: TimeEntry.with(id: 1, start: now.addingTimeInterval(-200), duration: 100))
        ]

        assertReducerFlow(
            initialState: initialState,
            reducer: reducer,
            steps:
            Step(.send, StartEditAction.autocompleteSuggestionsUpdated(autocompleteSuggestions)) {
                $0.autocompleteSuggestions = autocompleteSuggestions
            })
    }

    func testProjectButtonTappedNoSpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with no space at the end"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .projectButtonTapped) { $0.editableTimeEntry?.description = "test with no space at the end @" }
        )
    }

    func testProjectButtonTappedASpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with a space at the end "),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .projectButtonTapped) { $0.editableTimeEntry?.description = "test with a space at the end @" }
        )
    }

    func testProjectChipTappedNoSpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with no space at the end"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .addProjectChipTapped) { $0.editableTimeEntry?.description = "test with no space at the end @" }
        )
    }

    func testProjectChipTappedASpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with a space at the end "),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .addProjectChipTapped) { $0.editableTimeEntry?.description = "test with a space at the end @" }
        )
    }

    func testTagButtonTappedWithNoSpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with no space at the end"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .tagButtonTapped) { $0.editableTimeEntry?.description = "test with no space at the end #" }
        )
    }

    func testTagButtonTappedWithASpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with a space at the end "),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .tagButtonTapped) { $0.editableTimeEntry?.description = "test with a space at the end #" }
        )
    }

    func testAddTagChipTappedWithNoSpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with no space at the end"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .addTagChipTapped) { $0.editableTimeEntry?.description = "test with no space at the end #" }
        )
    }

    func testAddTagChipTappedWithASpaceAtTheEnd() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "test with a space at the end "),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated([])),
            Step(.send, .addTagChipTapped) { $0.editableTimeEntry?.description = "test with a space at the end #" }
        )
    }

    func testBillableButtonTapped() {

        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .billableButtonTapped) { $0.editableTimeEntry?.billable = true },
            Step(.send, .billableButtonTapped) { $0.editableTimeEntry?.billable = false }
        )
    }

    func testDurationInputtedForRunningTimeEntry() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(TimeEntry(
                id: 1,
                description: "sss",
                start: mockTime.now() - 10,
                duration: nil,
                billable: true,
                workspaceId: mockUser.defaultWorkspace,
                tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newDuration: TimeInterval = 40
        let newStartTime = mockTime.now() - newDuration

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .durationInputted(newDuration)) { $0.editableTimeEntry!.start = newStartTime }
        )
    }

    func testDurationInputtedForStoppedTimeEntry() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(TimeEntry(
                id: 1,
                description: "sss",
                start: mockTime.now() - 10,
                duration: 100,
                billable: true,
                workspaceId: mockUser.defaultWorkspace,
                tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newDuration: TimeInterval = 200

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .durationInputted(newDuration)) { $0.editableTimeEntry!.duration = newDuration }
        )
    }

    func testDurationInputtedWithInvalidDuration() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromSingle(TimeEntry(
                id: 1,
                description: "sss",
                start: mockTime.now() - 10,
                duration: 100,
                billable: true,
                workspaceId: mockUser.defaultWorkspace,
                tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newDuration: TimeInterval = -1

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .durationInputted(newDuration))
        )
    }

    func testDurationInputtedForTimeEntryGroup() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromGroup(
                ids: [0, 3, 4],
                groupSample: TimeEntry(
                    id: 1,
                    description: "sss",
                    start: mockTime.now() - 10,
                    duration: 100,
                    billable: true,
                    workspaceId: mockUser.defaultWorkspace,
                    tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newDuration: TimeInterval = 100

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .durationInputted(newDuration))
        )
    }

    func testWheelStartDateChanged() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromGroup(
                ids: [0, 3, 4],
                groupSample: TimeEntry(
                    id: 1,
                    description: "sss",
                    start: mockTime.now() - 10,
                    duration: 100,
                    billable: true,
                    workspaceId: mockUser.defaultWorkspace,
                    tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newStart = mockTime.now() - 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .wheelStartTimeChanged(newStart), { $0.editableTimeEntry!.start = newStart })
        )
    }

    func testWheelDurationChanged() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromGroup(
                ids: [0, 3, 4],
                groupSample: TimeEntry(
                    id: 1,
                    description: "sss",
                    start: mockTime.now() - 10,
                    duration: 100,
                    billable: true,
                    workspaceId: mockUser.defaultWorkspace,
                    tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newDuration: TimeInterval = 150

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .wheelDurationChanged(newDuration), { $0.editableTimeEntry!.duration = newDuration })
        )
    }

    func testWheelStartAndDurationChanged() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.fromGroup(
                ids: [0, 3, 4],
                groupSample: TimeEntry(
                    id: 1,
                    description: "sss",
                    start: mockTime.now() - 10,
                    duration: 100,
                    billable: true,
                    workspaceId: mockUser.defaultWorkspace,
                    tagIds: [])),
            autocompleteSuggestions: [],
            dateTimePickMode: .none, cursorPosition: 0
        )

        let newStart: Date = mockTime.now() - 20
        let newDuration: TimeInterval = 150

        assertReducerFlow(
        initialState: state,
        reducer: reducer,
        steps:
        Step(.send, .wheelStartAndDurationChanged(newStart, newDuration), {
            $0.editableTimeEntry!.start = newStart
            $0.editableTimeEntry!.duration = newDuration
        }))
    }

    func test_tagCreated_addsTagToEntitiesAndEditableTimeEntry() {
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: TimeLogEntities(),
            editableTimeEntry: EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace),
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0
        )

        let expectedTag = Tag(id: 0, name: "Test tag", workspaceId: mockUser.defaultWorkspace)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .tagCreated(expectedTag)) {
                $0.entities.tags[expectedTag.id] = expectedTag
                $0.editableTimeEntry!.tagIds.append(expectedTag.id)
            }
        )
    }

    func descriptionEnteredStep(for description: String) -> Step<StartEditState, StartEditAction> {
        return Step(.send, StartEditAction.descriptionEntered(description, description.count)) {
            $0.editableTimeEntry!.description = description
            $0.cursorPosition = description.count
        }
    }
}
