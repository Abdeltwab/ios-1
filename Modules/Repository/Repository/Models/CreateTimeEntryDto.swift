import Foundation
import Models

public struct CreateTimeEntryDto: Equatable {
    public let workspaceId: Int64
    public let description: String
    public let billable: Bool
    public let start: Date
    public let duration: TimeInterval
    public let projectId: Int64?
    public let taskId: Int64?
    public let tagIds: [Int64]

    public init(
        workspaceId: Int64,
        description: String,
        billable: Bool,
        start: Date,
        duration: TimeInterval,
        projectId: Int64?,
        taskId: Int64?,
        tagIds: [Int64]
    ) {
        self.workspaceId = workspaceId
        self.description = description
        self.billable = billable
        self.start = start
        self.duration = duration
        self.projectId = projectId
        self.taskId = taskId
        self.tagIds = tagIds
    }
}

extension TimeEntry {
    public func toCreateTimeEntryDto() -> CreateTimeEntryDto {
        guard let duration = self.duration else { fatalError("CreateTimeEntryDto requires a duration") }
        return CreateTimeEntryDto(
            workspaceId: self.workspaceId,
            description: self.description,
            billable: self.billable,
            start: self.start,
            duration: duration,
            projectId: self.projectId,
            taskId: self.taskId,
            tagIds: self.tagIds
        )
    }
}
