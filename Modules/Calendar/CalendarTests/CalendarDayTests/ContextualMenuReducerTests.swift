import XCTest
import CalendarService
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
import RxBlocking
import Timer
@testable import Calendar

// swiftlint:disable type_body_length
class ContextualMenuReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<ContextualMenuState, ContextualMenuAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        reducer = createContextualMenuReducer()
    }

    func test_closeButtonTapped_withATimeEntrySelected_setsSelectedItemToNil() {

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.closeButtonTapped) {
                $0.selectedItem = nil
            }
        )
    }

    func test_closeButtonTapped_withACalendarItemSelected_setsSelectedItemToNil() {

        let calendarEvent = CalendarEvent(id: "1", calendarId: "1", description: "Potato", start: now, stop: now, color: "")

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .right(calendarEvent),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.closeButtonTapped) {
                $0.selectedItem = nil
            }
        )
    }

    func test_dismissButtonTapped_withATimeEntrySelected_setsSelectedItemToNil() {

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.dismissButtonTapped) {
                $0.selectedItem = nil
            }
        )
    }

    func test_dissmissButtonTapped_withACalendarItemSelected_setsSelectedItemToNil() {

        let calendarEvent = CalendarEvent(id: "1", calendarId: "1", description: "Potato", start: now, stop: now, color: "")

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .right(calendarEvent),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.dismissButtonTapped) {
                $0.selectedItem = nil
            }
        )
    }
    
    func test_saveButtonTapped_withANewTimeEntrySelected_createsANewTimeEntry() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = mockTime.now()
        editableTimeEntry.duration = 600

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .saveButtonTapped) { $0.selectedItem = nil},
            Step(.receive, .timeEntries(.createTimeEntry(editableTimeEntry.toCreateTimeEntryDto())))
        )
    }

    func test_saveButtonTapped_withAnExistingTimeEntrySelected_updatesThatTimeEntry() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.ids = [0]
        editableTimeEntry.start = mockTime.now()
        editableTimeEntry.duration = 600
        
        var timeEntry = TimeEntry.init(id: 0,
                                       description: "",
                                       start: mockTime.now(),
                                       duration: 300,
                                       billable: false,
                                       workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection<TimeEntry>([timeEntry])
        )
        
        timeEntry.duration = 600

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.saveButtonTapped) { $0.selectedItem = nil},
            Step(.receive, .timeEntries(.updateTimeEntry(timeEntry)))
        )
    }

    func test_stopButtonTapped_setsSelectedItemToNilAndEmitsStopRunningTimeEntry() {
        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, ContextualMenuAction.stopButtonTapped) {
                $0.selectedItem = nil
            },
            Step(.receive, ContextualMenuAction.timeEntries(.stopRunningTimeEntry))
        )
    }

    func test_continueButtonTapped_withATimeEntrySelected_createsANewTimeEntry() {

        let timeEntry = TimeEntry(id: 0,
                                  description: "Hello, I'm a time entry",
                                  start: now.addingTimeInterval(-50),
                                  duration: 10,
                                  billable: false,
                                  workspaceId: 0)
        let editableTimeEntry = EditableTimeEntry.fromSingle(timeEntry)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection([timeEntry])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .continueButtonTapped) {
                $0.selectedItem = nil
            },
            Step(.receive, .timeEntries(.continueTimeEntry(0)))
        )
    }

    func test_deleteButtonTapped_withATimeEntrySelected_deletesTheTimeEntry() {

        let timeEntry = TimeEntry(id: 0,
                                  description: "Hello, I'm a time entry",
                                  start: now.addingTimeInterval(-50),
                                  duration: 10,
                                  billable: false,
                                  workspaceId: 0)
        let editableTimeEntry = EditableTimeEntry.fromSingle(timeEntry)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection([timeEntry])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .deleteButtonTapped) {
                $0.selectedItem = nil
            },
            Step(.receive, .timeEntries(.deleteTimeEntry(0)))
        )
    }

    func test_editButtonTapped_withATimeEntrySelected_setsEditableTimeEntry() {

        let timeEntry = TimeEntry(id: 0,
                                  description: "Hello, I'm a time entry",
                                  start: now.addingTimeInterval(-50),
                                  duration: 10,
                                  billable: false,
                                  workspaceId: 0)
        let editableTimeEntry = EditableTimeEntry.fromSingle(timeEntry)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .left(editableTimeEntry),
            timeEntries: EntityCollection([timeEntry])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .editButtonTapped) {
                $0.selectedItem = nil
                $0.editableTimeEntry = editableTimeEntry
            }
        )
    }

    func test_editButtonTapped_withNoTimeEntrySelected_doesNothing() {

        let timeEntry = TimeEntry(id: 0,
                                  description: "Hello, I'm a time entry",
                                  start: now.addingTimeInterval(-50),
                                  duration: 10,
                                  billable: false,
                                  workspaceId: 0)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: nil,
            timeEntries: EntityCollection([timeEntry])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .editButtonTapped)
        )
    }

    func test_startFromEventButtonTapped_withACalendarEventSelected_startsATimeEntry() {

        let calendarEvent = CalendarEvent(id: "1",
                                          calendarId: "1",
                                          description: "I'm a calendar event",
                                          start: now,
                                          stop: now.addingTimeInterval(10),
                                          color: "")

        let expectedDto = calendarEvent.toStartTimeEntryDto(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .right(calendarEvent),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .startFromEventButtonTapped) {
                $0.selectedItem = nil
            },
            Step(.receive, .timeEntries(.startTimeEntry(expectedDto)))
        )
    }

    func test_copyAsTimeEntryButtonTapped_withACalendarEventSelected_createsATimeEntry() {

        let calendarEvent = CalendarEvent(id: "1",
                                          calendarId: "1",
                                          description: "I'm a calendar event",
                                          start: now,
                                          stop: now.addingTimeInterval(10),
                                          color: "")
        
        let expectedDto = calendarEvent.toCreateTimeEntryDto(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            user: .loaded(mockUser),
            selectedItem: .right(calendarEvent),
            timeEntries: EntityCollection<TimeEntry>([])
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .copyAsTimeEntryButtonTapped) {
                $0.selectedItem = nil
            },
            Step(.receive, .timeEntries(.createTimeEntry(expectedDto)))
        )
    }
}
