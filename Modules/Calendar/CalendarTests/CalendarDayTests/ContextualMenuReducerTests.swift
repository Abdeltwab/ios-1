import XCTest
import CalendarService
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
import RxBlocking
import Timer
@testable import Calendar

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
            selectedItem: .left(editableTimeEntry),
            timeEntries: [:]
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
            selectedItem: .right(calendarEvent),
            timeEntries: [:]
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
            selectedItem: .left(editableTimeEntry),
            timeEntries: [:]
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
            selectedItem: .right(calendarEvent),
            timeEntries: [:]
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

    func test_stopButtonTapped_setsSelectedItemToNilAndEmitsStopRunningTimeEntry() {
        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)

        let state = ContextualMenuState(
            selectedItem: .left(editableTimeEntry),
            timeEntries: [Int64: TimeEntry]()
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
            selectedItem: .left(editableTimeEntry),
            timeEntries: [0: timeEntry]
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
            selectedItem: .left(editableTimeEntry),
            timeEntries: [0: timeEntry]
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
            selectedItem: .left(editableTimeEntry),
            timeEntries: [0: timeEntry]
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
            selectedItem: nil,
            timeEntries: [0: timeEntry]
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .editButtonTapped)
        )
    }
}
