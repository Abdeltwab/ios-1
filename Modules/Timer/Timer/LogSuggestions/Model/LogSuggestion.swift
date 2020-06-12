import Foundation
import Models

struct SuggestionProperties: Equatable {
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

enum LogSuggestion {
    case mostUsed(SuggestionProperties)
    case calendar(SuggestionProperties)
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
