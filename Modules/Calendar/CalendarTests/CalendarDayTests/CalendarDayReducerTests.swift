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

    func test_startTimeDraggedAction_changesSelectedItemStartTime() {

        let state = CalendarDayState(
            selectedDate: now,
            timeEntries: [:],
            calendarEvents: [:],
            selectedItem: .left(EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace))
        )

        let newTime = now.addingTimeInterval(20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, CalendarDayAction.startTimeDragged(newTime)) {
                guard case var .left(editableTimeEntry) = $0.selectedItem else {
                    return
                }
                editableTimeEntry.start = newTime
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
}
