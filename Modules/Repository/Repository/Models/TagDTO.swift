import Foundation
import Models

public struct TagDTO {
    public let name: String
    public let workspaceId: Int64

    public init(
        name: String,
        workspaceId: Int64) {
        self.name = name
        self.workspaceId = workspaceId
    }
}

extension Tag {
    public func toTagDTO() -> TagDTO {
        return TagDTO(name: self.name, workspaceId: self.workspaceId)
    }
}
