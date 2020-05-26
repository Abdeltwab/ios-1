import Foundation

public struct TimeLogEntities: Equatable {
    public var workspaces = [Int64: Workspace]()
    public var clients = [Int64: Client]()
    public var timeEntries = [Int64: TimeEntry]()
    public var projects = [Int64: Project]()
    public var tasks = [Int64: Task]()
    public var tags = [Int64: Tag]()
    
    public init() {
    }
    
    public func getWorkspace(_ id: Int64?) -> Workspace? {
        guard let id = id else { return nil }
        return workspaces[id]
    }
    
    public func getClient(_ id: Int64?) -> Client? {
        guard let id = id else { return nil }
        return clients[id]
    }
    
    public func getTimeEntry(_ id: Int64?) -> TimeEntry? {
        guard let id = id else { return nil }
        return timeEntries[id]
    }
    
    public func getProject(_ id: Int64?) -> Project? {
        guard let id = id else { return nil }
        return projects[id]
    }
    
    public func getTask(_ id: Int64?) -> Task? {
        guard let id = id else { return nil }
        return tasks[id]
    }
    
    public func getTag(_ id: Int64?) -> Tag? {
        guard let id = id else { return nil }
        return tags[id]
    }
}

extension Dictionary where Dictionary.Key == Int64, Dictionary.Value == TimeEntry {
    public var runningTimeEntry: TimeEntry? {
        values.first(where: { timeEntry -> Bool in
            timeEntry.duration == nil
        })
    }
}
