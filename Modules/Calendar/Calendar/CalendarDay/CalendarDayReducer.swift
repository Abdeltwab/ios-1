import Architecture
import CalendarService
import Foundation
import Models
import OtherServices
import Repository
import RxSwift
import Timer

// swiftlint:disable cyclomatic_complexity
func createCalendarDayReducer(calendarService: CalendarService) -> Reducer<CalendarDayState, CalendarDayAction> {
    return Reducer {state, action -> [Effect<CalendarDayAction>] in

        switch action {

        case .calendarViewAppeared:
            return [fetchCalendarEventsEffect(calendarService: calendarService, date: state.selectedDate)]

        case .calendarEventsFetched(let events):
            let keyedEvents = events.reduce(into: [String: CalendarEvent](), { $0[$1.id] = $1 })
            state.calendarEvents = keyedEvents
            return []

        case .startTimeDragged(let newStart):
            guard case var .left(editableTimeEntry) = state.selectedItem else { return [] }
            guard let oldStart = editableTimeEntry.start, let duration = editableTimeEntry.duration else { return [] }
            editableTimeEntry.start = newStart
            editableTimeEntry.duration = duration - newStart.timeIntervalSince(oldStart)
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .stopTimeDragged(let newStop):
            guard case var .left(editableTimeEntry) = state.selectedItem else { return [] }
            guard let start = editableTimeEntry.start, start <= newStop else { return [] }
            editableTimeEntry.duration = newStop.timeIntervalSince(start)
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .timeEntryDragged(let newStart):
            guard case var .left(editableTimeEntry) = state.selectedItem else { return [] }
            editableTimeEntry.start = newStart
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .emptyPositionLongPressed(let start):
            guard state.selectedItem == nil else { return [] }
            guard case let Loadable.loaded(user) = state.user else { return [] }
            var editableTimeEntry = EditableTimeEntry.empty(workspaceId: user.defaultWorkspace)
            editableTimeEntry.start = start
            editableTimeEntry.duration = defaultTimeEntryDuration
            state.selectedItem = .left(editableTimeEntry)
            return []
        }
    }
}
// swiftlint:enable cyclomatic_complexity

func fetchCalendarEventsEffect(calendarService: CalendarService, date: Date) -> Effect<CalendarDayAction> {
    let startDate = date.ignoreTimeComponents()
    let endDate = date.ignoreTimeComponents().addingTimeInterval(TimeInterval(hours: 24))

    return calendarService
        .getAvailableCalendars()
        .map({ calendarService.getCalendarEvents(between: startDate, and: endDate, in: $0) })
        .flatMap({ $0 })
        .map({ CalendarDayAction.calendarEventsFetched($0) })
        .toEffect()
}
