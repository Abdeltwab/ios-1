import XCTest
import Architecture
import ArchitectureTestSupport
import Models
import OtherServices
@testable import Timer

extension StartEditReducerTests {
    func test_autocomplete_withTagToken_returnsTagsMatchingByName() {
        let tags = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Tag(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace) }
        
        let expectedSuggestions = tags[..<2].sorted(by: {leftHand, rightHand in
            leftHand.name > rightHand.name
        }).map(AutocompleteSuggestion.tagSuggestion)
        
        var entities = TimeLogEntities()
        entities.tags = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })
        
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
            descriptionEnteredStep(for: "#Match"),
            Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
                $0.autocompleteSuggestions = expectedSuggestions
            }
        )
    }
    
    func test_autocomplete_withTagToken_returnsTagsOnlyInCurrentWorkspace() {
        let tags = ["Match", "Match as well", "Not this", "Nor this"].enumerated()
            .map { Tag(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace + Int64($0.offset)) }

        let expectedSuggestions = [AutocompleteSuggestion.tagSuggestion(tag: tags[0])]

        var entities = TimeLogEntities()
        entities.tags = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })

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
           descriptionEnteredStep(for: "#Match"),
           Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
               $0.autocompleteSuggestions = expectedSuggestions
           }
        )
    }
    
    func test_autocomplete_withTagToken_showsTheCreateSuggestionWhenTheresNoFullMatch() {
        let tags = ["Matching", "Matching as well", "Not this", "Nor this"].enumerated()
            .map { Tag(id: Int64($0.offset), name: $0.element, workspaceId: mockUser.defaultWorkspace) }
        
        var expectedSuggestions = tags[..<2].sorted(by: {leftHand, rightHand in
            leftHand.name > rightHand.name
        }).map(AutocompleteSuggestion.tagSuggestion)
        expectedSuggestions.insert(AutocompleteSuggestion.createTagSuggestion(name: "Match"), at: 0)

        var entities = TimeLogEntities()
        entities.tags = Dictionary(uniqueKeysWithValues: tags.map { ($0.id, $0) })

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
           descriptionEnteredStep(for: "#Match"),
           Step(.receive, StartEditAction.autocompleteSuggestionsUpdated(expectedSuggestions)) {
               $0.autocompleteSuggestions = expectedSuggestions
           }
        )
    }
}
