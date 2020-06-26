import CalendarService
import Models
import OtherServices

let calendarItemsSelector: (CalendarDayState, Time) -> [CalendarItem] = { state, time in

    let date = state.selectedDate
    let isTimeEntryIncluded: (TimeEntry) -> Bool = { timeEntry in
        if let stop = timeEntry.stop {
            return timeEntry.start >= date && stop <= date.addingTimeInterval(.secondsInADay)
        } else {
            let duration = time.now().timeIntervalSince(timeEntry.start)
            return timeEntry.start >= date && duration <= .secondsInADay
        }
    }

    let isCalendarEventIncluded: (CalendarEvent) -> Bool = { calendarEvent in
        return calendarEvent.start >= date && calendarEvent.stop <= date.addingTimeInterval(.secondsInADay)
    }

    let replaceSelectedItemIfNeeded: (CalendarItem.Value) -> (CalendarItem.Value) = { currentItem in
        guard let selectedItem = state.selectedItem else { return currentItem }
        switch (selectedItem, currentItem) {
        case (.left(let editableTimeEntry), .timeEntry(let timeEntry)):
            return editableTimeEntry.ids.first == timeEntry.id ? .selectedItem(selectedItem) : currentItem
        case (.right(let selectedCalendarEvent), .calendarEvent(let calendarEvent)):
            return selectedCalendarEvent.id == calendarEvent.id ? .selectedItem(selectedItem) : currentItem
        default:
            return currentItem
        }
    }

    let timeEntries = state.entities.timeEntries
        .filter(isTimeEntryIncluded)
        .map(CalendarItem.Value.timeEntry)
        .map(replaceSelectedItemIfNeeded)

    let calendarEvents = state.calendarEvents.values
        .filter(isCalendarEventIncluded)
        .map(CalendarItem.Value.calendarEvent)
        .map(replaceSelectedItemIfNeeded)

    let newEditableTimeEntry: [CalendarItem.Value]
    if let selectedItem = state.selectedItem, let emptyIds = selectedItem.left?.ids.isEmpty, emptyIds {
        newEditableTimeEntry = [.selectedItem(selectedItem)]
    } else {
        newEditableTimeEntry = []
    }

    let values = timeEntries + calendarEvents + newEditableTimeEntry
    let calculator = CalendarLayoutCalculator(time: time, entities: state.entities)
    return calculator.calculateLayoutAttributesforItems(calendarItems: values)
}
