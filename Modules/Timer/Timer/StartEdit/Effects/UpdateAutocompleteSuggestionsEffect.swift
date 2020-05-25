import Foundation
import Architecture
import Models
import RxSwift
import Repository

func updateAutocompleteSuggestionsEffect(
    _ query: String,
    _ cursorPosition: Int,
    _ entities: TimeLogEntities
) -> [Effect<StartEditAction>] {
    if query.isEmpty {
        return [Single.just(StartEditAction.autocompleteSuggestionsUpdated([])).toEffect()]
    }

    let (token, actualQuery) = query.findTokenAndQueryMatchesForAutocomplete(["@", "#"], cursorPosition)

    let suggestions: [AutocompleteSuggestion] = {
        switch token {
        case "@": return fetchProjectSuggestions(for: actualQuery, in: entities)
        case "#": return fetchTagSuggestions(for: actualQuery, in: entities)
        default: return fetchTimeEntrySuggestions(for: actualQuery, in: entities)
        }
    }()

    return [
        Single.just(suggestions)
            .map(StartEditAction.autocompleteSuggestionsUpdated)
            .toEffect()
    ]
}

func fetchProjectSuggestions(for query: String, in entities: TimeLogEntities) -> [AutocompleteSuggestion] {
    func clientNameMatches(_ word: String, _ project: Project) -> Bool {
        guard let client = entities.getClient(project.clientId) else { return false }
        return client.name.contains(word)
    }

    let words = query.split(separator: " ").map { String($0) }

    var suggestions = words.reduce(Array(entities.projects.values)) { projects, word in
        return projects.filter { project in
            return project.name.contains(word)
                || clientNameMatches(word, project)
        }
    }.sorted(by: { leftHand, rightHand in
        leftHand.name > rightHand.name
    }).map(AutocompleteSuggestion.projectSuggestion)
    suggestions.insert(AutocompleteSuggestion.createProjectSuggestion(name: query), at: 0)
    return suggestions
}

func fetchTagSuggestions(for query: String, in entities: TimeLogEntities) -> [AutocompleteSuggestion] {
    return []
}

func fetchTimeEntrySuggestions(for query: String, in entities: TimeLogEntities) -> [AutocompleteSuggestion] {
    func projectOrClientNameMatches(_ word: String, _ timeEntry: TimeEntry) -> Bool {
        guard let project = entities.getProject(timeEntry.projectId) else { return false }
        if project.name.contains(word) { return true }
        guard let client = entities.getClient(project.clientId) else { return false }
        return client.name.contains(word)
    }

    func tagNamesMatch(_ word: String, _ timeEntry: TimeEntry) -> Bool {
        guard timeEntry.tagIds.count > 0 else { return false }
        let tags = timeEntry.tagIds.compactMap(entities.getTag)
        if tags.count == 0 { return false }
        return tags.map { $0.name.contains(word) }
            .contains(true)
    }

    func taksNameMatches(_ word: String, _ timeEntry: TimeEntry) -> Bool {
        guard let task = entities.getTask(timeEntry.taskId) else { return false }
        return task.name.contains(word)
    }

    let words = query.split(separator: " ").map { String($0) }

    return words.reduce(Array(entities.timeEntries.values)) { timeEntries, word in
        return timeEntries.filter { timeEntry in
            return timeEntry.description.contains(word)
                || projectOrClientNameMatches(word, timeEntry)
                || tagNamesMatch(word, timeEntry)
                || taksNameMatches(word, timeEntry)
        }
    }.sorted(by: { leftHand, rightHand in
        leftHand.description > rightHand.description
    }).map(AutocompleteSuggestion.timeEntrySuggestion)
}
