import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
import RxBlocking
import Timer
@testable import Calendar

class CalendarDayReducerTests: XCTestCase {

    var now = Date(timeIntervalSince1970: 987654321)
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<CalendarDayState, CalendarDayAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        reducer = createCalendarDayReducer()
    }

    func test_startTimeDraggedAction_changesSelectedItemStartTimeAndDuration() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let newTime = now.addingTimeInterval(20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(newTime)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.start = newTime
                editableTimeEntry.duration = 40
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_startTimeDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: nil
        )

        let newTime = now.addingTimeInterval(20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(newTime))
        )
    }

    func test_stopTimeDraggedAction_changesSelectedItemDuration() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10
        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let newTime = now.addingTimeInterval(80)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.stopTimeDragged(newTime)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.duration = 30
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_stopTimeDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: nil
        )

        let newTime = now.addingTimeInterval(20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(newTime))
        )
    }

    func test_timeEntryDraggedAction_changesSelectedItemStart() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let newTime = now.addingTimeInterval(80)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.timeEntryDragged(newTime)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.start = newTime
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_timeEntryDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: nil
        )

        let newTime = now.addingTimeInterval(20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(newTime))
        )
    }
}
