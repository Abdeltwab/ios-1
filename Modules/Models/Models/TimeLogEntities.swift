import Foundation

public struct TimeLogEntities: Equatable {
    public var workspaces = EntityCollection<Workspace>([])
    public var clients = EntityCollection<Client>([])
    public var timeEntries = EntityCollection<TimeEntry>([])
    public var projects = EntityCollection<Project>([])
    public var tasks = EntityCollection<Task>([])
    public var tags = EntityCollection<Tag>([])

    public init() {
    }

    public func getWorkspace(_ id: Int64?) -> Workspace? {
        guard let id = id else { return nil }
        return workspaces[id: id]
    }

    public func getClient(_ id: Int64?) -> Client? {
        guard let id = id else { return nil }
        return clients[id: id]
    }

    public func getTimeEntry(_ id: Int64?) -> TimeEntry? {
        guard let id = id else { return nil }
        return timeEntries[id: id]
    }

    public func getProject(_ id: Int64?) -> Project? {
        guard let id = id else { return nil }
        return projects[id: id]
    }

    public func getTask(_ id: Int64?) -> Task? {
        guard let id = id else { return nil }
        return tasks[id: id]
    }

    public func getTag(_ id: Int64?) -> Tag? {
        guard let id = id else { return nil }
        return tags[id: id]
    }
}

extension EntityCollection where EntityType == TimeEntry {
    public var runningTimeEntry: TimeEntry? {
        entities.first(where: { timeEntry -> Bool in
            timeEntry.duration == nil
        })
    }
}
