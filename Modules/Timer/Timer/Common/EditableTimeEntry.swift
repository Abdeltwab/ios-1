import Foundation
import Models
import Repository

public struct EditableTimeEntry: Equatable {
    public var ids: [Int64]
    public var workspaceId: Int64
    public var description: String
    public var billable: Bool
    public var start: Date?
    public var duration: TimeInterval?
    public var projectId: Int64?
    public var taskId: Int64?
    public var tagIds: [Int64]
    public var editableProject: EditableProject?
    
    private init(
        ids: [Int64],
        workspaceId: Int64,
        description: String,
        billable: Bool,
        start: Date? = nil,
        duration: TimeInterval? = nil,
        projectId: Int64? = nil,
        taskId: Int64? = nil,
        tagIds: [Int64] = [],
        editableProject: EditableProject? = nil
    ) {
        self.ids = ids
        self.workspaceId = workspaceId
        self.description = description
        self.billable = billable
        self.start = start
        self.duration = duration
        self.projectId = projectId
        self.taskId = taskId
        self.tagIds = tagIds
        self.editableProject = editableProject
    }
    
    public static func empty(workspaceId: Int64) -> EditableTimeEntry {
        return EditableTimeEntry(
            ids: [],
            workspaceId: workspaceId,
            description: "",
            billable: false
        )
    }
    
    public static func fromSingle(_ timeEntry: TimeEntry) -> EditableTimeEntry {
        return EditableTimeEntry(
            ids: [timeEntry.id],
            workspaceId: timeEntry.workspaceId,
            description: timeEntry.description,
            billable: timeEntry.billable,
            start: timeEntry.start,
            duration: timeEntry.duration,
            projectId: timeEntry.projectId,
            taskId: timeEntry.taskId,
            tagIds: timeEntry.tagIds
        )
    }
    
    public static func fromGroup(ids: [Int64], groupSample: TimeEntry) -> EditableTimeEntry {
        return EditableTimeEntry(
            ids: ids,
            workspaceId: groupSample.workspaceId,
            description: groupSample.description,
            billable: groupSample.billable,
            projectId: groupSample.projectId,
            taskId: groupSample.taskId,
            tagIds: groupSample.tagIds
        )
    }
}

extension EditableTimeEntry {
    func toStartTimeEntryDto() -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: self.workspaceId,
            description: self.description,
            tagIds: self.tagIds
        )
    }

    var isRunningOrNew: Bool {
        return self.duration == nil
    }

    var isGroup: Bool {
        return self.ids.count > 1
    }
}

extension EditableTimeEntry {
    var stop: Date? {
        guard let start = start, let duration = duration else { return nil }
        return start + duration
    }

    var minStart: Date? {
        guard let stop = stop else { return nil }
        return stop - .maxTimeEntryDuration
    }

    var maxStart: Date? { return stop }

    var minStop: Date? { return start }

    var maxStop: Date? {
        guard let start = start else { return nil }
        return start + .maxTimeEntryDuration }
}
