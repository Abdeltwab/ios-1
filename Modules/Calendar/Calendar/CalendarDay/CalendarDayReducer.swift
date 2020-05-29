import Foundation
import Architecture
import Models
import RxSwift
import Repository
import OtherServices

func createCalendarDayReducer() -> Reducer<CalendarDayState, CalendarDayAction> {
    return Reducer {state, action -> [Effect<CalendarDayAction>] in

        switch action {

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
        }
    }
}
