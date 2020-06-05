import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
@testable import Timer

extension StartEditReducerTests {
    func test_autocomplete_withProjectToken_returnsProjectsMatchingByName() {
        let projects = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Project.with(id: Int64($0.offset), name: $0.element) }

        var expectedSuggestions = projects[..<2].sorted(by: {leftHand, rightHand in
            leftHand.name > rightHand.name
        }).map(AutocompleteSuggestion.projectSuggestion)
        expectedSuggestions.insert(AutocompleteSuggestion.createProjectSuggestion(name: "Match"), at: 0)

        var entities = TimeLogEntities()
        entities.projects = EntityCollection(projects)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 6)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "@Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withProjectToken_returnsProjectsMatchingByClientName() {
        let clients = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Client(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace)}
        let projects = clients.map { client -> Project in
            Project.with(name: "Project with client \(client.id)", clientId: client.id)
        }

        var expectedSuggestions = projects[..<2].sorted(by: {leftHand, rightHand in
            leftHand.name > rightHand.name
        }).map(AutocompleteSuggestion.projectSuggestion)
        expectedSuggestions.insert(AutocompleteSuggestion.createProjectSuggestion(name: "Match"), at: 0)

        var entities = TimeLogEntities()
        entities.clients = EntityCollection(clients)
        entities.projects = EntityCollection(projects)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 6)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "@Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withProjectToken_returnsProjectsMatchingMultipleWordsAcrossMultipleEntities() {
        let tags = tagsForAutocompletionTest()
        let clients = clientsForAutocompletionTest()
        let projects = projectsForAutocompletionTest()
        let tasks = tasksForAutocompletionTest()
        let timeEntries = timeEntriesForAutocompletionTest()

        var expectedSuggestions = [projects.first!, projects.last!].sorted(by: {leftHand, rightHand in
                leftHand.name > rightHand.name
            }).map(AutocompleteSuggestion.projectSuggestion)
        expectedSuggestions.insert(AutocompleteSuggestion.createProjectSuggestion(name: "word1 word2"), at: 0)

        var entities = TimeLogEntities()
        entities.tags = EntityCollection(tags)
        entities.clients = EntityCollection(clients)
        entities.projects = EntityCollection(projects)
        entities.tasks = EntityCollection(tasks)
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 20)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Testing @word1 word2"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }
}
