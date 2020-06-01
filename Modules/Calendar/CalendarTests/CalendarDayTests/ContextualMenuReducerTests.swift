import XCTest
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
            selectedItem: .left(editableTimeEntry)
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
        
        let state = ContextualMenuState(
            selectedItem: .right("calendarItemId")
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
            selectedItem: .left(editableTimeEntry)
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
        
        let state = ContextualMenuState(
            selectedItem: .right("calendarItemId")
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
}
