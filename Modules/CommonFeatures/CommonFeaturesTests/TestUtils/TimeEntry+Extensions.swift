import Foundation
import Models

extension TimeEntry {
    static func with(
        id: Int64? = nil,
        description: String = "",
        billable: Bool = false,
        start: Date? = nil,
        duration: TimeInterval? = nil,
        workspaceId: Int64 = 0,
        tagIds: [Int64] = []) -> TimeEntry {
        let timeEntryId = id ?? Int64(UUID().hashValue)
        return TimeEntry(
            id: timeEntryId,
            description: description,
            start: start ?? Date(),
            duration: duration,
            billable: billable,
            workspaceId: workspaceId,
            tagIds: tagIds)
    }
}
