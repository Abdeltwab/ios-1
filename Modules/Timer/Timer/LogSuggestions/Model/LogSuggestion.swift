import Foundation
import Models
import CalendarService
import Repository

public struct SuggestionProperties: Equatable {
    public let description: String
    public let projectId: Int64?
    public let taskId: Int64?
    public let projectColor: String?
    public let projectName: String?
    public let taskName: String?
    public let clientName: String?
    public let hasProject: Bool
    public let hasClient: Bool
    public let hasTask: Bool
    public let workspaceId: Int64
    public let isBillable: Bool
    public let tagIds: [Int64]
    public let startTime: Date
    public let duration: TimeInterval
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
            projectColor: project?.color,
            projectName: project?.name,
            taskName: task?.name,
            clientName: client?.name,
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
            projectColor: nil,
            projectName: nil,
            taskName: nil,
            clientName: nil,
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
