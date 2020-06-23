import UIKit
import Models
import Utils
import Assets

public struct TimeEntryViewModel: Equatable {

    public static func == (lhs: TimeEntryViewModel, rhs: TimeEntryViewModel) -> Bool {
        return lhs.description == rhs.description && lhs.projectTaskClient == rhs.projectTaskClient && lhs.billable == rhs.billable
            && lhs.start == rhs.start && lhs.duration == rhs.duration
            && lhs.end == rhs.end && lhs.isRunning == rhs.isRunning //&& lhs.tags == rhs.tags
    }

    public let id: Int64
    public let groupId: Int
    public let description: String
    public let projectTaskClient: NSAttributedString
    public let billable: Bool

    public let start: Date
    public let duration: TimeInterval?
    public let durationString: String?
    public let end: Date?
    public let isRunning: Bool

    public let descriptionColor: UIColor
    public let projectColor: UIColor

    public let tags: [Tag]

    public init(
        timeEntry: TimeEntry,
        project: Project? = nil,
        client: Client? = nil,
        task: Task? = nil,
        tags: [Tag] = []) {

        self.id = timeEntry.id
        self.groupId = timeEntry.groupId
        self.description = timeEntry.description.isEmpty ? "No description" : timeEntry.description
        self.projectTaskClient = attributedStringFrom(project: project, task: task, client: client)
        self.billable = timeEntry.billable

        self.start = timeEntry.start
        self.duration = timeEntry.duration
        self.durationString = duration?.formattedDuration()
        self.end = duration.map({ timeEntry.start.addingTimeInterval($0) }) ?? nil
        isRunning = duration == nil

        descriptionColor = timeEntry.description.isEmpty
            ? Color.textSecondary.uiColor
            : Color.textPrimary.uiColor
        projectColor = project == nil ? .clear : UIColor(hex: project!.color)

        self.tags = tags
    }
}

private func attributedStringFrom(project: Project?, task: Task?, client: Client?) -> NSAttributedString {
    return projectClientTaskString(projectName: project?.name,
                            projectColor: project?.color,
                            taskName: task?.name,
                            clientName: client?.name)
}
