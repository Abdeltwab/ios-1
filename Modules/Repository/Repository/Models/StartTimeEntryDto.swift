import Foundation
import Models

public struct StartTimeEntryDto: Equatable {
    public let workspaceId: Int64
    public let description: String
    public let billable: Bool
    public let projectId: Int64?
    public let taskId: Int64?
    public let tagIds: [Int64]

    public init(
        workspaceId: Int64,
        description: String,
        billable: Bool,
        projectId: Int64?,
        taskId: Int64?,
        tagIds: [Int64]
    ) {
        self.workspaceId = workspaceId
        self.description = description
        self.billable = billable
        self.projectId = projectId
        self.taskId = taskId
        self.tagIds = tagIds
    }

    public static func empty(workspaceId: Int64) -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: workspaceId,
            description: "",
            billable: false,
            projectId: nil,
            taskId: nil,
            tagIds: []
        )
    }
}

extension TimeEntry {
    public func toStartTimeEntryDto() -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: self.workspaceId,
            description: self.description,
            billable: self.billable,
            projectId: self.projectId,
            taskId: self.taskId,
            tagIds: self.tagIds
        )
    }
}
