import Foundation
import Models

public struct CreateTimeEntryDto: Equatable {
    public let workspaceId: Int64
    public let description: String
    public let start: Date
    public let duration: TimeInterval

    public init(
        workspaceId: Int64,
        description: String,
        start: Date,
        duration: TimeInterval
    ) {
        self.description = description
        self.workspaceId = workspaceId
        self.start = start
        self.duration = duration
    }
}

extension TimeEntry {
    public func toCreateTimeEntryDto() -> CreateTimeEntryDto {
        guard let duration = self.duration else { fatalError("CreateTimeEntryDto requires a duration") }
        return CreateTimeEntryDto(workspaceId: self.workspaceId, description: self.description, start: self.start, duration: duration)
    }
}
