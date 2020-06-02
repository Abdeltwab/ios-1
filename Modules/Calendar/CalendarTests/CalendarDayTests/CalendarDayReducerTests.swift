import XCTest
import CalendarService
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
    var mockCalendarEvents: [CalendarEvent]!
    var reducer: Reducer<CalendarDayState, CalendarDayAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        mockCalendarEvents = [
            CalendarEvent(id: "1", calendarId: "1", description: "Hello there", start: now, stop: now, color: ""),
            CalendarEvent(id: "2", calendarId: "1", description: "TWSS", start: now, stop: now, color: "")
        ]
        reducer = createCalendarDayReducer(calendarService: MockCalendarService(calendarEvents: mockCalendarEvents))
    }

    func test_calendarViewAppeared_loadsCalendarEvents() {
        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .calendarViewAppeared),
            Step(.receive, .calendarEventsFetched(mockCalendarEvents)) { state in
                state.calendarEvents = self.mockCalendarEvents.reduce(into: [:], { $0[$1.id] = $1 })
            }
        )
    }

    func test_startTimeDraggedAction_changesSelectedItemStartTimeAndDuration() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10

        let state = CalendarDayState(
            user: .loaded(mockUser),
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
            user: .loaded(mockUser),
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
            user: .loaded(mockUser),
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
            user: .loaded(mockUser),
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
            user: .loaded(mockUser),
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
            user: .loaded(mockUser),
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

    func test_emptyPositionLongPressed_setsAnEditableTimeEntry() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.emptyPositionLongPressed(now)) {
                var editableTimeEntry = EditableTimeEntry.empty(workspaceId: 0)
                editableTimeEntry.start = self.now
                editableTimeEntry.duration = defaultTimeEntryDuration
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_emptyPositionLongPressed_whenselectedItemIsNotNil_shouldDoNothing() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: .left(EditableTimeEntry.empty(workspaceId: 0))
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.emptyPositionLongPressed(now))
        )
    }
}
