import Architecture
import CalendarService
import Foundation
import Models
import OtherServices
import Repository
import RxSwift
import Timer
import Utils

// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
func createCalendarDayReducer(calendarService: CalendarService) -> Reducer<CalendarDayState, CalendarDayAction> {
    return Reducer {state, action -> [Effect<CalendarDayAction>] in

        switch action {

        case .calendarViewAppeared:
            return [fetchCalendarEventsEffect(calendarService: calendarService, date: state.selectedDate)]

        case .calendarEventsFetched(let events):
            let keyedEvents = events.reduce(into: [String: CalendarEvent](), { $0[$1.id] = $1 })
            state.calendarEvents = keyedEvents
            return []

        case .startTimeDragged(let timeInterval):
            let newStart = state.selectedDate + timeInterval
            guard newStart >= state.selectedDate else { return [] }
            guard case var .left(editableTimeEntry) = state.selectedItem else { return [] }
            guard let oldStart = editableTimeEntry.start, let duration = editableTimeEntry.duration else { return [] }
            editableTimeEntry.start = newStart
            editableTimeEntry.duration = duration - newStart.timeIntervalSince(oldStart)
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .stopTimeDragged(let timeInterval):
            let newStop = state.selectedDate + timeInterval
            guard newStop < state.selectedDate + .secondsInADay else { return [] }
            guard case var .left(editableTimeEntry) = state.selectedItem else { return [] }
            guard let start = editableTimeEntry.start, start <= newStop else { return [] }
            editableTimeEntry.duration = newStop.timeIntervalSince(start)
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .timeEntryDragged(let timeInterval):
            let newStart = state.selectedDate + timeInterval
            guard newStart >= state.selectedDate else { return [] }
            guard case var .left(editableTimeEntry) = state.selectedItem, let duration = editableTimeEntry.duration else { return [] }
            guard newStart + duration < state.selectedDate + .secondsInADay else { return [] }
            editableTimeEntry.start = newStart
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .emptyPositionLongPressed(let timeInterval):
            let start = state.selectedDate + timeInterval
            guard case let Loadable.loaded(user) = state.user else { return [] }
            var editableTimeEntry = EditableTimeEntry.empty(workspaceId: user.defaultWorkspace)
            editableTimeEntry.start = start
            editableTimeEntry.duration = defaultTimeEntryDuration
            state.selectedItem = .left(editableTimeEntry)
            return []

        case .itemTapped(let calendarItem):
            switch calendarItem.value {
            case .timeEntry(let timeEntry):
                state.selectedItem = .left(EditableTimeEntry.fromSingle(timeEntry))
            case .selectedItem(let selectedItem):
                state.selectedItem = selectedItem
            case .calendarEvent(let calendarEvent):
                state.selectedItem = .right(calendarEvent)
            }
            return []
        }
    }
}
// swiftlint:enable function_body_length
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
