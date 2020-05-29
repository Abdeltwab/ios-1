import Foundation
import Models

public struct ProjectDTO {
    public let name: String
    public let isPrivate: Bool
    public let isActive: Bool
    public let color: String
    public let billable: Bool?
    public let workspaceId: Int64
    public let clientId: Int64?

    public init(name: String,
                isPrivate: Bool = true,
                isActive: Bool = true,
                color: String = "#ffffff",
                billable: Bool = false,
                workspaceId: Int64,
                clientId: Int64? = nil) {
        self.name = name
        self.isPrivate = isPrivate
        self.isActive = isActive
        self.color = color
        self.billable = billable
        self.workspaceId = workspaceId
        self.clientId = clientId

    }
}

extension Project {
    public func toProjectDTO() -> ProjectDTO {
        return ProjectDTO(name: self.name, workspaceId: self.workspaceId)
    }
}
