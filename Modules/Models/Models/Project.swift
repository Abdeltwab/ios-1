import Foundation

public struct Project: Codable, Entity, Equatable {
    
    public var id: Int64
    public var name: String
    public var isPrivate: Bool
    public var isActive: Bool
    public var color: String
    public var billable: Bool?
    
    public var workspaceId: Int64
    public var clientId: Int64?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case isPrivate = "is_private"
        case isActive = "active"
        case color
        case billable
        
        case workspaceId = "workspace_id"
        case clientId = "client_id"
    }

    public init(
        id: Int64,
        name: String,
        isPrivate: Bool,
        isActive: Bool,
        color: String,
        billable: Bool?,
        workspaceId: Int64,
        clientId: Int64?
    ) {
        self.id = id
        self.name = name
        self.isPrivate = isPrivate
        self.isActive = isActive
        self.color = color
        self.billable = billable
        self.workspaceId = workspaceId
        self.clientId = clientId
    }
    
    public static let defaultColors = [
        "#0B83D9", "#9E5BD9", "#D94182", "#E36A00", "#BF7000",
        "#C7AF14", "#D92B2B", "#2DA608", "#06A893", "#C9806B",
        "#465BB3", "#990099", "#566614", "#525266"
    ]
}
