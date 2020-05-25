import XCTest
import Architecture
import Models
import OtherServices
@testable import Timer

extension StartEditReducerTests {
    func clientsForAutocompletionTest() -> [Client] {
        return [
            Client(id: 0, name: "word1", workspaceId: mockUser.defaultWorkspace),
            Client(id: 1, name: "word1 word2", workspaceId: mockUser.defaultWorkspace)
        ]
    }

    func projectsForAutocompletionTest() -> [Project] {
        return [
            Project.with(
                id: 0,
                name: "word2word1",
                clientId: 0
            ),
            Project.with(
                id: 1,
                name: "word1",
                clientId: 0
            ),
            Project.with(
                id: 2,
                name: "word2",
                clientId: 1
            )
        ]
    }

    func tagsForAutocompletionTest() -> [Tag] {
        return [
            Tag(id: 0, name: "word1 word2word3", workspaceId: mockUser.defaultWorkspace),
            Tag(id: 1, name: "word1", workspaceId: mockUser.defaultWorkspace)
        ]
    }

    func tasksForAutocompletionTest() -> [Task] {
        return [
            Task.with(id: 0, name: "word1word2", projectId: 1),
            Task.with(id: 1, name: "word2", projectId: 1)
        ]
    }

    func timeEntriesForAutocompletionTest() -> [TimeEntry] {
        return [
            timeEntryMatchByName(),
            timeEntryMatchByProjectName(),
            timeEntryMatchByClientName(),
            timeEntryMatchByTagName(),
            timeEntryMatchByTaskName(),
            timeEntryDontMatchByName(),
            timeEntryDontMatchByProjectName(),
            timeEntryDontMatchByTagName(),
            timeEntryDontMatchByTaskName()
        ]
    }

    func timeEntryMatchByName() -> TimeEntry {
        return TimeEntry.with(id: 0, description: "a word2 word1")
    }

    func timeEntryMatchByProjectName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 1, description: "b word2 word3")
        timeEntry.projectId = 0
        return timeEntry
    }

    func timeEntryMatchByClientName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 2, description: "c wo rd 2")
        timeEntry.projectId = 2
        return timeEntry
    }

    func timeEntryMatchByTagName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 3, description: "d wo rd1 wo rd2")
        timeEntry.tagIds = [0]
        return timeEntry
    }

    func timeEntryMatchByTaskName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 4, description: "e word1")
        timeEntry.taskId = 0
        return timeEntry
    }

    func timeEntryDontMatchByName() -> TimeEntry {
        return TimeEntry.with(id: 5, description: "f word4")
    }

    func timeEntryDontMatchByProjectName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 6, description: "g word5")
        timeEntry.projectId = 1
        return timeEntry
    }

    func timeEntryDontMatchByTagName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 7, description: "h w o r d 1 w o r d 2")
        timeEntry.tagIds = [1]
        return timeEntry
    }

    func timeEntryDontMatchByTaskName() -> TimeEntry {
        var timeEntry = TimeEntry.with(id: 8, description: "i wor1dword2")
        timeEntry.taskId = 1
        return timeEntry
    }
}
