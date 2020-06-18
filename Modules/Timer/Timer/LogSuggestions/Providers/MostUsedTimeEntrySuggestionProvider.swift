import Foundation
import Utils
import OtherServices
import Repository
import Models
import RxSwift

class MostUsedTimeEntrySuggestionProvider: SuggestionPrivider {
    private static let daysBackToQuery: Int = 42
    private let thresholdPeriod = TimeInterval(days: daysBackToQuery)
    private let timeLogEntities: TimeLogEntities
    private let time: Time
    private let maxNumberOfSuggestions: Int

    init(time: Time, timeLogEntities: TimeLogEntities, maxNumberOfSuggestions: Int) {
        self.time = time
        self.timeLogEntities = timeLogEntities
        self.maxNumberOfSuggestions = maxNumberOfSuggestions
    }

    public func getSuggestions() -> [LogSuggestion] {
        let timeEntriesSuitableForSuggestion = timeLogEntities.timeEntries.entities
            .filter(self.isSuitableForSuggestion)

        return mostUsed(entries: timeEntriesSuitableForSuggestion)
            .take(self.maxNumberOfSuggestions)
            .map(toLogSuggestions)
    }

    // swiftlint:disable todo
    private func isSuitableForSuggestion(entry: TimeEntry) -> Bool {
        let hasDescription = !entry.description.isEmpty
        let hasProject = entry.projectId != nil
        let delta = time.now() - entry.start
        let isRecent = delta <= thresholdPeriod
        let isActive = isTimeEntryActive(entry)
        // TODO:
        let isSynced = true //timeEntry.SyncStatus == SyncStatus.inSync

        return isRecent && isActive && isSynced && (hasDescription || hasProject)
    }

    private func isTimeEntryActive(_ entry: TimeEntry) -> Bool {
        let project = timeLogEntities.getProject(entry.projectId)
        // TODO:
//        entry.isDeleted == false
//            && !entry.isInaccessible
        return project?.isActive ?? true
    }
    // swiftlint:enable todo

    // swiftlint:disable nesting
    private func mostUsed(entries: [TimeEntry]) -> [TimeEntry] {
        struct GroupingKey: Hashable {
            let description: String
            let projectId: Int64?
            let taskId: Int64?
        }

        return entries
            .grouped(by: { GroupingKey(description: $0.description, projectId: $0.projectId, taskId: $0.taskId) })
            .sorted { $0.count > $1.count }
            .compactMap { $0.first }
    }
    // swiftlint:enable nesting

    private func toLogSuggestions(_ entry: TimeEntry) -> LogSuggestion {
        let project = timeLogEntities.getProject(entry.projectId)
        let client = timeLogEntities.getClient(project?.clientId)
        let task = timeLogEntities.getTask(entry.taskId)
        return entry.toMostUsedLogSuggestion(project: project, client: client, task: task)
    }
}
