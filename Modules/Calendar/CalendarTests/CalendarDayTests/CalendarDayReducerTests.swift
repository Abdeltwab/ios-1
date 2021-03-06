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
            CalendarEvent(id: "1",
                          calendarId: "1",
                          calendarName: "",
                          description: "Hello there",
                          start: now,
                          stop: now,
                          color: ""),
            CalendarEvent(id: "2",
                          calendarId: "1",
                          calendarName: "",
                          description: "TWSS",
                          start: now,
                          stop: now,
                          color: "")
        ]
        reducer = createCalendarDayReducer(calendarService: MockCalendarService(calendarEvents: mockCalendarEvents))
    }

    func test_calendarViewAppeared_loadsCalendarEvents() {
        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            entities: TimeLogEntities(),
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
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(timeInterval)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.start = self.now + timeInterval
                editableTimeEntry.duration = 40
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_startTimeDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(timeInterval))
        )
    }

    func test_stopTimeDraggedAction_changesSelectedItemDuration() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.stopTimeDragged(timeInterval)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.duration = 10
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_stopTimeDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(timeInterval))
        )
    }

    func test_timeEntryDraggedAction_changesSelectedItemStart() {

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        editableTimeEntry.start = now.addingTimeInterval(50)
        editableTimeEntry.duration = 10

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.timeEntryDragged(timeInterval)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else { return }
                editableTimeEntry.start = self.now + timeInterval
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_timeEntryDraggedAction_whenNoEditableTimeEntryIsNil_shouldDoNothing() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        let timeInterval: TimeInterval = 20

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(timeInterval))
        )
    }

    func test_emptyPositionLongPressed_setsAnEditableTimeEntry() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.emptyPositionLongPressed(0)) {
                var editableTimeEntry = EditableTimeEntry.empty(workspaceId: 0)
                editableTimeEntry.start = self.now
                editableTimeEntry.duration = defaultTimeEntryDuration
                $0.selectedItem = .left(editableTimeEntry)
            }
        )
    }

    func test_itemTapped_withATimeEntry_selectsTimeEntry() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        let timeEntry = TimeEntry(id: 1, description: "Potato", start: now, duration: 10, billable: false, workspaceId: 0)
        let calendarItem = CalendarItem(value: .timeEntry(timeEntry), columnIndex: 0, totalColumns: 1, duration: 10)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .itemTapped(calendarItem)) {
                $0.selectedItem = .left(EditableTimeEntry.fromSingle(timeEntry))
            }
        )
    }

    func test_itemTapped_withACalendarEvent_selectsCalendarEvent() {

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: nil
        )

        let calendarEvent = CalendarEvent(id: "1",
                                          calendarId: "1",
                                          calendarName: "",
                                          description: "Potato",
                                          start: now,
                                          stop: now.addingTimeInterval(10),
                                          color: "")
        let calendarItem = CalendarItem(value: .calendarEvent(calendarEvent), columnIndex: 0, totalColumns: 1, duration: 10)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .itemTapped(calendarItem)) {
                $0.selectedItem = .right(calendarEvent)
            }
        )
    }

    func test_itemTapped_withAlreadySelectedItem_selectsTheNewItem() {

        let timeEntry = TimeEntry(id: 1, description: "Potato", start: now, duration: 10, billable: false, workspaceId: 0)
        let calendarEvent = CalendarEvent(id: "1",
                                          calendarId: "1",
                                          calendarName: "",
                                          description: "Potato",
                                          start: now,
                                          stop: now.addingTimeInterval(10),
                                          color: "")

        let state = CalendarDayState(
            user: .loaded(mockUser),
            selectedDate: now,
            entities: TimeLogEntities(),
            calendarEvents: [:],
            selectedItem: .left(EditableTimeEntry.fromSingle(timeEntry))
        )

        let calendarItem = CalendarItem(value: .calendarEvent(calendarEvent), columnIndex: 0, totalColumns: 1, duration: 10)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .itemTapped(calendarItem)) {
                $0.selectedItem = .right(calendarEvent)
            }
        )
    }
}
// swiftlint:enable type_body_length
