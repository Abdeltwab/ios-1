import Foundation
import Models

public struct StartTimeEntryDto: Equatable {
    public let workspaceId: Int64
    public let description: String
    public let tagIds: [Int64]
    
    public init(
        workspaceId: Int64,
        description: String,
        tagIds: [Int64]
    ) {
        self.description = description
        self.workspaceId = workspaceId
        self.tagIds = tagIds
    }
    
    public static func empty(workspaceId: Int64) -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: workspaceId,
            description: "",
            tagIds: []
        )
    }
}

extension TimeEntry {
    public func toStartTimeEntryDto() -> StartTimeEntryDto {
        return StartTimeEntryDto(workspaceId: self.workspaceId, description: self.description, tagIds: self.tagIds)
    }
}
