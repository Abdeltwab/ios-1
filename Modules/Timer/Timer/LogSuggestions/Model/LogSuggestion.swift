import Foundation
import Models
import CalendarService
import Repository

public struct SuggestionProperties: Equatable {
    let description: String
    let projectId: Int64?
    let taskId: Int64?
    let projectColor: String
    let projectName: String
    let taskName: String
    let clientName: String
    let hasProject: Bool
    let hasClient: Bool
    let hasTask: Bool
    let workspaceId: Int64
    let isBillable: Bool
    let tagIds: [Int64]
    let startTime: Date
    let duration: TimeInterval
}

extension SuggestionProperties {
    public func toStartTimeEntryDto() -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: self.workspaceId,
            description: self.description,
            billable: self.isBillable,
            projectId: self.projectId,
            taskId: self.taskId,
            tagIds: self.tagIds
        )
    }
}

public enum LogSuggestion {
    case mostUsed(SuggestionProperties)
    case calendar(SuggestionProperties)

    var properties: SuggestionProperties {
        switch self {
        case .mostUsed(let property):
            return property
        case .calendar(let property):
            return property
        }
    }
}

extension LogSuggestion: Equatable { }

extension TimeEntry {
    func toMostUsedLogSuggestion(project: Project?, client: Client?, task: Task?) -> LogSuggestion {
        let properties = SuggestionProperties(
            description: description,
            projectId: projectId,
            taskId: taskId,
            projectColor: project?.color ?? "",
            projectName: project?.name ?? "",
            taskName: task?.name ?? "",
            clientName: client?.name ?? "",
            hasProject: project != nil,
            hasClient: client != nil,
            hasTask: task != nil,
            workspaceId: workspaceId,
            isBillable: billable,
            tagIds: tagIds,
            startTime: start,
            duration: duration ?? 0)

        return LogSuggestion.mostUsed(properties)
    }
}

extension CalendarEvent {
    func toCalendarLogSuggestion(defaultWorkspaceId: Int64) -> LogSuggestion {
        let properties = SuggestionProperties(
            description: description,
            projectId: nil,
            taskId: nil,
            projectColor: "",
            projectName: "",
            taskName: "",
            clientName: "",
            hasProject: false,
            hasClient: false,
            hasTask: false,
            workspaceId: defaultWorkspaceId,
            isBillable: false,
            tagIds: [],
            startTime: start,
            duration: duration)

        return LogSuggestion.calendar(properties)
    }
}
