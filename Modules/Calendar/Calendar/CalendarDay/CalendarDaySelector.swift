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

    let timeEntries = state.timeEntries.values
        .filter(isTimeEntryIncluded)
        .map(CalendarItem.Value.timeEntry)

    let calendarEvents = state.calendarEvents.values
        .filter(isCalendarEventIncluded)
        .map(CalendarItem.Value.calendarEvent)

    let values = timeEntries + calendarEvents
    let calculator = CalendarLayoutCalculator(time: time)
    return calculator.calculateLayoutAttributesforItems(calendarItems: values)
}
