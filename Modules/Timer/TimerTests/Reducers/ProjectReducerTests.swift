import XCTest
import Architecture
import Models
import OtherServices
@testable import Timer

class ProjectReducerTests: XCTestCase {
    var now = Date(timeIntervalSince1970: 987654321)
    var mockRepository: MockTimeLogRepository!
    var mockTime: Time!
    var mockUser: User!
    var reducer: Reducer<ProjectState, ProjectAction>!

    override func setUp() {
        mockTime = Time(getNow: { return self.now })
        mockRepository = MockTimeLogRepository(time: mockTime)
        mockUser = User(id: 0, apiToken: "token", defaultWorkspace: 0)
        
        reducer = createProjectReducer(repository: mockRepository)
    }

    func testNameEntered() {

        let state = ProjectState(
            editableProject: EditableProject.empty(workspaceId: mockUser.defaultWorkspace),
            projects: [:]
        )

        let expectedName = "potato"

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .nameEntered(expectedName)) {
                $0.editableProject?.name = expectedName
            }
        )
    }

    func testNameEnteredClearsTheError() {

        let state = ProjectState(
            editableProject: EditableProject.empty(workspaceId: mockUser.defaultWorkspace),
            projects: [1: Project.init(id: 1,
                                       name: "potato",
                                       isPrivate: true,
                                       isActive: true,
                                       color: "",
                                       billable: false,
                                       workspaceId: 0,
                                       clientId: nil)]
        )

        let expectedName = "potato"
        let fixedName = "potato2"

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .nameEntered(expectedName)) {
                $0.editableProject?.name = expectedName
            },
            Step(.send, .doneButtonTapped) {
                $0.editableProject?.hasError = true
            },
            Step(.send, .nameEntered(fixedName)) {
                $0.editableProject?.name = fixedName
                $0.editableProject?.hasError = false
            }
        )
    }

    func testTogglePrivateProject() {
        let state = ProjectState(
            editableProject: EditableProject.empty(workspaceId: mockUser.defaultWorkspace),
            projects: [:]
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .privateProjectSwitchTapped) {
                $0.editableProject?.isPrivate = false
            },
            Step(.send, .privateProjectSwitchTapped) {
                $0.editableProject?.isPrivate = true
            }
        )
    }

    func testDoneButtonPressed() {
        let state = ProjectState(
            editableProject: EditableProject.empty(workspaceId: mockUser.defaultWorkspace),
            projects: [:]
        )

        let expectedName = "potato"

        let expectedProject = Project(id: mockRepository.newProjectId,
                                      name: expectedName,
                                      isPrivate: true,
                                      isActive: true,
                                      color: "#ffffff",
                                      billable: false,
                                      workspaceId: 0,
                                      clientId: nil)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .nameEntered(expectedName)) {
                $0.editableProject?.name = expectedName
            },
            Step(.send, .doneButtonTapped),
            Step(.receive, .projectCreated(expectedProject)) {
                $0.editableProject = nil
                $0.projects = [self.mockRepository.newProjectId: expectedProject]
            }
        )
    }

    func testDoneButtonPressedSetsAnErrorWhenProjectIsDuplicated() {
        
        let expectedName = "potato"

        let state = ProjectState(
            editableProject: EditableProject.empty(workspaceId: mockUser.defaultWorkspace),
            projects: [1: Project(id: 1,
                                  name: expectedName,
                                  isPrivate: true,
                                  isActive: true,
                                  color: "",
                                  billable: false,
                                  workspaceId: 0,
                                  clientId: nil)]
        )

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            Step(.send, .nameEntered(expectedName)) {
                $0.editableProject?.name = expectedName
            },
            Step(.send, .doneButtonTapped) {
                $0.editableProject?.hasError = true
            }
        )
    }
}
