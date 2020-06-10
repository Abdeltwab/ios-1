import Foundation
import RxSwift
import Models
import API
import OtherServices
import Database

public protocol TimeLogRepository {
    func getWorkspaces() -> Single<[Workspace]>
    func getClients() -> Single<[Client]>
    func getTimeEntries() -> Single<[TimeEntry]>
    func getProjects() -> Single<[Project]>
    func getTasks() -> Single<[Task]>
    func getTags() -> Single<[Tag]>
    func startTimeEntry(_ timeEntry: StartTimeEntryDto) -> Single<(started: TimeEntry, stopped: TimeEntry?)>
    func createTimeEntry(_ timeEntry: CreateTimeEntryDto) -> Single<TimeEntry>
    func updateTimeEntry(_ timeEntry: TimeEntry) -> Single<Void>
    func deleteTimeEntry(timeEntryId: Int64) -> Single<Void>
    func createProject(_ project: ProjectDTO) -> Single<Project>
    func createTag(_ project: TagDTO) -> Single<Tag>
}

public class Repository {
    // These mock the DB
    private var timeEntries = [TimeEntry]()
    private var workspaces = [Workspace]()
    private var clients = [Client]()
    private var projects = [Project]()
    private var tasks = [Task]()
    private var tags = [Tag]()
    // ------------------------
    
    private let time: Time
    private let api: TimelineAPI
    private let database: Database
  
    public init(api: TimelineAPI, database: Database, time: Time) {
        self.api = api
        self.time = time
        self.database = database
    }
}

extension Repository: TimeLogRepository {

    public func getWorkspaces() -> Single<[Workspace]> {
        database.workspaces.rx.getAll()
    }
    
    public func getClients() -> Single<[Client]> {
        database.clients.rx.getAll()
    }
    
    public func getTimeEntries() -> Single<[TimeEntry]> {
        database.timeEntries.rx.getAllSortedBackground()
    }
    
    public func getProjects() -> Single<[Project]> {
        database.projects.rx.getAll()
    }
    
    public func getTasks() -> Single<[Task]> {
        database.tasks.rx.getAll()
    }
    
    public func getTags() -> Single<[Tag]> {
        database.tags.rx.getAll()
    }

    public func startTimeEntry(_ timeEntry: StartTimeEntryDto) -> Single<(started: TimeEntry, stopped: TimeEntry?)> {
        do {
            let timeEntries = try database.timeEntries.getAllRunning()
            
            var stoppedTimeEntry: TimeEntry?
            if var runningEntry = timeEntries.first {
                runningEntry.duration = time.now().timeIntervalSince(runningEntry.start)
                try database.timeEntries.update(entity: runningEntry)
                stoppedTimeEntry = runningEntry
            }

            // NOTE: How we resolve the new id is a temporary hack, it's meant to change once the sync team gets to this.
            let newTimeEntry = TimeEntry(
                id: (timeEntries.map({ $0.id }).max() ?? 0) + 1,
                description: timeEntry.description,
                start: time.now(),
                duration: nil,
                billable: false,
                workspaceId: timeEntry.workspaceId,
                tagIds: timeEntry.tagIds
            )
            try database.timeEntries.insert(entity: newTimeEntry)
            return Single.just((started: newTimeEntry, stopped: stoppedTimeEntry))
        } catch let error {
            return Single.error(error)
        }
    }

    public func createTimeEntry(_ dto: CreateTimeEntryDto) -> Single<TimeEntry> {
        do {
            let timeEntries = try database.timeEntries.getAll()
            // NOTE: How we resolve the new id is a temporary hack, it's meant to change once the sync team gets to this.
            let newTimeEntry = TimeEntry(id: (timeEntries.map({ $0.id }).max() ?? 0) + 1,
                                         description: dto.description,
                                         start: dto.start,
                                         duration: dto.duration,
                                         billable: false,
                                         workspaceId: dto.workspaceId,
                                         tagIds: []
            )
            try database.timeEntries.insert(entity: newTimeEntry)
            return .just(newTimeEntry)
        } catch {
            return .error(error)
        }
    }
    
    public func updateTimeEntry(_ timeEntry: TimeEntry) -> Single<Void> {
        return Single.just(())
    }
    
    public func deleteTimeEntry(timeEntryId: Int64) -> Single<Void> {
        return database.timeEntries.rx.delete(id: timeEntryId)
    }

    public func createProject(_ project: ProjectDTO) -> Single<Project> {
        do {
            let projects = try database.projects.getAll()
            // NOTE: How we resolve the new id is a temporary hack, it's meant to change once the sync team gets to this.
            let newProject = Project(id: (projects.map({ $0.id }).max() ?? 0) + 1,
                                     name: project.name,
                                     isPrivate: project.isPrivate,
                                     isActive: project.isActive,
                                     color: project.color,
                                     billable: project.billable,
                                     workspaceId: project.workspaceId,
                                     clientId: project.clientId)
            try database.projects.insert(entity: newProject)
            return .just(newProject)
        } catch {
            return .error(error)
        }
    }

    public func createTag(_ tag: TagDTO) -> Single<Tag> {
        do {
            let tags = try database.tags.getAll()
            // NOTE: How we resolve the new id is a temporary hack, it's meant to change once the sync team gets to this.
            let newTag = Tag(
                id: (tags.map({ $0.id }).max() ?? 0) + 1,
                name: tag.name,
                workspaceId: tag.workspaceId)
            try database.tags.insert(entity: newTag)
            return .just(newTag)
        } catch {
            return .error(error)
        }
    }
}
