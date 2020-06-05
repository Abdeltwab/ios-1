import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
@testable import Timer

extension StartEditReducerTests {
    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingByDescription() {
        let timeEntries = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { TimeEntry.with(id: Int64($0.offset), description: $0.element) }

        let expectedSuggestions = timeEntries[..<2].sorted(by: {leftHand, rightHand in
            leftHand.description > rightHand.description
        }).map(AutocompleteSuggestion.timeEntrySuggestion)

        var entities = TimeLogEntities()
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingByProjectName() {
        let projects = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Project.with(id: Int64($0.offset), name: $0.element) }
        let timeEntries = projects.map { project -> TimeEntry in
            var timeEntry = TimeEntry.with(description: "Time entry for \(project.id)")
            timeEntry.projectId = project.id
            return timeEntry
        }

        let expectedSuggestions = timeEntries[..<2].sorted(by: {leftHand, rightHand in
            leftHand.description > rightHand.description
        }).map(AutocompleteSuggestion.timeEntrySuggestion)

        var entities = TimeLogEntities()
        entities.projects = EntityCollection(projects)
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingByClientName() {
        let clients = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Client(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace)}
        let projects = clients.map { client -> Project in
            Project.with(clientId: client.id)
        }
        let timeEntries = projects.map { project -> TimeEntry in
            var timeEntry = TimeEntry.with(description: "Time entry for \(project.id)")
            timeEntry.projectId = project.id
            return timeEntry
        }

        let expectedSuggestions = timeEntries[..<2].sorted(by: {leftHand, rightHand in
            leftHand.description > rightHand.description
        }).map(AutocompleteSuggestion.timeEntrySuggestion)

        var entities = TimeLogEntities()
        entities.clients = EntityCollection(clients)
        entities.projects = EntityCollection(projects)
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingByTaskName() {
        let tasks = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Task.with(id: Int64($0.offset), name: $0.element) }
        let timeEntries = tasks.map { task -> TimeEntry in
            var timeEntry = TimeEntry.with(description: "Time entry for \(task.id)")
            timeEntry.taskId = task.id
            return timeEntry
        }

        let expectedSuggestions = timeEntries[..<2].sorted(by: {leftHand, rightHand in
            leftHand.description > rightHand.description
        }).map(AutocompleteSuggestion.timeEntrySuggestion)

        var entities = TimeLogEntities()
        entities.tasks = EntityCollection(tasks)
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingByTagName() {
        let tags = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Tag(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace) }
        let timeEntries = tags.map { tag -> TimeEntry in
            var timeEntry = TimeEntry.with(description: "Time entry for \(tag.id)")
            timeEntry.tagIds = [tag.id]
            return timeEntry
        }

        let expectedSuggestions = timeEntries[..<2].sorted(by: {leftHand, rightHand in
            leftHand.description > rightHand.description
        }).map(AutocompleteSuggestion.timeEntrySuggestion)

        var entities = TimeLogEntities()
        entities.tags = EntityCollection(tags)
        entities.timeEntries = EntityCollection(timeEntries)

        let editableTimeEntry = EditableTimeEntry.empty(workspaceId: mockUser.defaultWorkspace)
        let state = StartEditState(
            user: Loadable.loaded(mockUser),
            entities: entities,
            editableTimeEntry: editableTimeEntry,
            autocompleteSuggestions: [],
            dateTimePickMode: .none,
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }

    func test_autocomplete_withNoTokens_returnsTimeEntriesMatchingMultipleWordsAcrossMultipleEntities() {
        let tags = tagsForAutocompletionTest()
        let clients = clientsForAutocompletionTest()
        let projects = projectsForAutocompletionTest()
        let tasks = tasksForAutocompletionTest()
        let timeEntries = timeEntriesForAutocompletionTest()

        let expectedSuggestions = timeEntries[..<5].sorted(by: {leftHand, rightHand in
                leftHand.description > rightHand.description
            }).map(AutocompleteSuggestion.timeEntrySuggestion)

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
            cursorPosition: 0)

        assertReducerFlow(
            initialState: state,
            reducer: reducer,
            steps:
            descriptionEnteredStep(for: "word1 word2"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }
}
