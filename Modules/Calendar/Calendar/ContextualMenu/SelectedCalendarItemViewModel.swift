import CalendarService
import Models
import Timer
import Utils

struct SelectedCalendarItemViewModel {

    var selectedItem: Either<EditableTimeEntry, CalendarEvent>
    var project: Project?

    var description: String {
        let itemDescription: String
        switch selectedItem {
        case .left(let editableTimeEntry):
            itemDescription = editableTimeEntry.description
        case .right(let calendarEvent):
            itemDescription = calendarEvent.description
        }
        return itemDescription.isEmpty ? "newTimeEntry".localized : itemDescription
    }

    var projectOrCalendar: String? {
        switch selectedItem {
        case .left:
            return project?.name
        case .right(let calendarEvent):
            return calendarEvent.calendarName
        }
    }

    var color: String? {
        switch selectedItem {
        case .left:
            return project?.color
        case .right(let calendarEvent):
            return calendarEvent.color
        }
    }

    var start: Date {
        switch selectedItem {
        case .left(let editableTimeEntry):
            return editableTimeEntry.start!
        case .right(let calendarEvent):
            return calendarEvent.start
        }
    }
    
    var duration: TimeInterval? {
        switch selectedItem {
        case .left(let editableTimeEntry):
            return editableTimeEntry.duration
        case .right(let calendarEvent):
            return calendarEvent.duration
        }
    }

    var stop: Date? {
        guard let duration = duration else { return nil }
        return start + duration
    }

    var formattedStartAndStop: String {
        if let stop = stop {
            return "\(start.toTimeString()) - \(stop.toTimeString())"
        }
        return "\(start.toTimeString()) - "
    }

    var isTimeEntry: Bool { selectedItem.left != nil }
    var isNewTimeEntry: Bool { isTimeEntry && selectedItem.left?.ids.isEmpty ?? false }
    var isRunningTimeEntry: Bool { isTimeEntry && selectedItem.left?.duration == nil }
    var isStoppedTimeEntry: Bool { isTimeEntry && !isRunningTimeEntry && !isNewTimeEntry }
    var isCalendarEvent: Bool { selectedItem.right != nil }
}
