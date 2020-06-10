import CalendarService
import Repository
import Models

extension CalendarEvent {
    func toStartTimeEntryDto(workspaceId: Int64) -> StartTimeEntryDto {
        return StartTimeEntryDto(
            workspaceId: workspaceId,
            description: self.description,
            billable: false,
            projectId: nil,
            taskId: nil,
            tagIds: [])
    }

    func toCreateTimeEntryDto(workspaceId: Int64) -> CreateTimeEntryDto {
        return CreateTimeEntryDto(
            workspaceId: workspaceId,
            description: self.description,
            billable: false,
            start: self.start,
            duration: self.duration,
            projectId: nil,
            taskId: nil,
            tagIds: []
        )
    }
}
