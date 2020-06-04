import CalendarService
import Repository
import Models

extension CalendarEvent {
    func toStartTimeEntryDto(workspaceId: Int64) -> StartTimeEntryDto {
        return StartTimeEntryDto(workspaceId: workspaceId, description: self.description, tagIds: [])
    }

    func toCreateTimeEntryDto(workspaceId: Int64) -> CreateTimeEntryDto {
        return CreateTimeEntryDto(workspaceId: workspaceId, description: self.description, start: self.start, duration: self.duration)
    }
}
