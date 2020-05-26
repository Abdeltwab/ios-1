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
    func updateTimeEntry(_ timeEntry: TimeEntry) -> Single<Void>
    func deleteTimeEntry(timeEntryId: Int64) -> Single<Void>
    func createProject(_ project: CreateProjectDto) -> Single<Project>
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
        if workspaces.isEmpty {
            return api.loadWorkspaces()
                .do(onSuccess: { self.workspaces = $0 })
        }

        return Single.just(workspaces)
    }
    
    public func getClients() -> Single<[Client]> {
        if clients.isEmpty {
            return api.loadClients()
                .do(onSuccess: { self.clients = $0 })
        }
        
        return Single.just(clients)
    }
    
    public func getTimeEntries() -> Single<[TimeEntry]> {
        database.timeEntries.rx.getAll()
//        if timeEntries.isEmpty {
//            return api.loadEntries()
//                .do(onSuccess: { self.timeEntries = $0 })
//        }
//
//        return Single.just(timeEntries)
    }
    
    public func getProjects() -> Single<[Project]> {
        if projects.isEmpty {
            return api.loadProjects()
                .do(onSuccess: { self.projects = $0 })
        }
        
        return Single.just(projects)
    }
    
    public func getTasks() -> Single<[Task]> {
        if tasks.isEmpty {
            return api.loadTasks()
                .do(onSuccess: { self.tasks = $0 })
        }
        
        return Single.just(tasks)
    }
    
    public func getTags() -> Single<[Tag]> {
        if tags.isEmpty {
            return api.loadTags()
                .do(onSuccess: { self.tags = $0 })
        }
        
        return Single.just(tags)
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
    
    public func updateTimeEntry(_ timeEntry: TimeEntry) -> Single<Void> {
        return Single.just(())
    }
    
    public func deleteTimeEntry(timeEntryId: Int64) -> Single<Void> {
        return database.timeEntries.rx.delete(id: timeEntryId)
    }

    public func createProject(_ project: CreateProjectDto) -> Single<Project> {
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
}
