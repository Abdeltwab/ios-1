import XCTest
import Architecture
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
        entities.projects = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
        
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
        entities.clients = Dictionary(uniqueKeysWithValues: clients.map { ($0.id, $0) })
        entities.projects = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
        
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
        entities.tags = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })
        entities.clients = Dictionary(uniqueKeysWithValues: clients.map { ($0.id, $0) })
        entities.projects = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
        entities.tasks = Dictionary(uniqueKeysWithValues: tasks.map { ($0.id, $0) })
        entities.timeEntries = Dictionary(uniqueKeysWithValues: timeEntries.map { ($0.id, $0) })
        
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
