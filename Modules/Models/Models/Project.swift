import Foundation

public struct Project: Codable, Entity, Equatable {
    
    public var id: Int
    public var name: String
    public var isPrivate: Bool
    public var isActive: Bool
    public var color: String
    public var billable: Bool?
    
    public var workspaceId: Int
    public var clientId: Int?
    
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
}
