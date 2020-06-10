import Models
import OtherServices
import Utils
import Timer
import XCTest
@testable import Calendar

class CalendarDaySelectorTests: XCTestCase {

    func test_selectsOnlyTimeEntriesFromTheSpecifiedDate() {
        let now = Date.with(2020, 1, 1)

        let expectedTimeEntries: [TimeEntry] = (0..<10)
            .map({ createTimeEntry(id: $0, start: now + 1 * .secondsInAnHour, duration: 10 * .secondsInAMinute, description: "Expected") })

        let notExpectedTimeEntries: [TimeEntry] = (10..<20)
            .map({ createTimeEntry(id: $0, start: now + 2 * .secondsInADay, duration: 10 * .secondsInAMinute, description: "Unexpected") })

        let timeEntries = EntityCollection(expectedTimeEntries + notExpectedTimeEntries)

        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: timeEntries,
            calendarEvents: [:]
        )

        let time: Time = Time(getNow: { now })
        let selectedTimeEntries = calendarItemsSelector(state, time)

        XCTAssertEqual(selectedTimeEntries.count, expectedTimeEntries.count)
        selectedTimeEntries.forEach {
            XCTAssertEqual($0.description, "Expected")
        }
    }

    func test_returnsAnEmptyArrayWhenThereAreNoYimeEntriesOnTheSpecifiedDate() {
        let now = Date.with(2020, 1, 1)

        let notExpectedTimeEntries: [TimeEntry] = (10..<20)
            .map({ createTimeEntry(id: $0, start: now + 2 * .secondsInADay, duration: 10 * .secondsInAMinute, description: "Unexpected") })

        let timeEntries = EntityCollection(notExpectedTimeEntries)

        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: timeEntries,
            calendarEvents: [:]
        )

        let time: Time = Time(getNow: { now })
        let selectedTimeEntries = calendarItemsSelector(state, time)

        XCTAssert(selectedTimeEntries.isEmpty)
    }

    func test_selectsOnlyTimeEntriesThatStartAndEndOnTheSpecifiedDate() {
        let now = Date.with(2020, 1, 1)

        let expectedTimeEntries: [TimeEntry] = (0..<10)
            .map({ createTimeEntry(id: $0, start: now + 1 * .secondsInAnHour, duration: 10 * .secondsInAMinute, description: "Expected") })

        let timeEntriesThatStartTheDayBefore: [TimeEntry] = (10..<20)
            .map({ createTimeEntry(id: $0, start: now - 2 * .secondsInAnHour, duration: 10 * .secondsInAnHour, description: "Unexpected") })

        let timeEntriesThatStopsTheDayAfter: [TimeEntry] = (10..<20)
        .map({ createTimeEntry(id: $0, start: now + 23 * .secondsInAnHour, duration: 10 * .secondsInAnHour, description: "Unexpected") })

        let timeEntries = EntityCollection(
            expectedTimeEntries
                + timeEntriesThatStartTheDayBefore
                + timeEntriesThatStopsTheDayAfter
        )

        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: timeEntries,
            calendarEvents: [:]
        )

        let time: Time = Time(getNow: { now })
        let selectedTimeEntries = calendarItemsSelector(state, time)

        XCTAssertEqual(selectedTimeEntries.count, expectedTimeEntries.count)
        selectedTimeEntries.forEach {
            XCTAssertEqual($0.description, "Expected")
        }
    }

    func test_replacesTheSelectedTimeEntry_whenSelectedItemIsAnExistingTimeEntry() {
        let now = Date.with(2020, 1, 1)

        let unselectedTimeEntries: [TimeEntry] = (0..<10)
            .map({ createTimeEntry(id: $0, start: now + 1 * .secondsInAnHour, duration: 10 * .secondsInAMinute, description: "Expected") })

        let selectedTimeEntry = createTimeEntry(id: 10, start: now + 1 * .secondsInAnHour, duration: 10 * .secondsInAMinute, description: "Expected")
        let editableTimeEntry = EditableTimeEntry.fromSingle(selectedTimeEntry)

        let timeEntries = EntityCollection(unselectedTimeEntries + [selectedTimeEntry])

        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: timeEntries,
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let time: Time = Time(getNow: { now })
        let selectedTimeEntries = calendarItemsSelector(state, time)

        XCTAssertEqual(selectedTimeEntries.count, unselectedTimeEntries.count + 1)
        selectedTimeEntries.forEach {
            XCTAssertEqual($0.description, "Expected")
        }
    }

    func test_replacesTheSelectedTimeEntry_whenSelectedItemIsANewTimeEntry() {
        let now = Date.with(2020, 1, 1)

        let unselectedTimeEntries: [TimeEntry] = (0..<10)
            .map({ createTimeEntry(id: $0, start: now + 1 * .secondsInAnHour, duration: 10 * .secondsInAMinute, description: "Expected") })

        var editableTimeEntry = EditableTimeEntry.empty(workspaceId: 0)
        editableTimeEntry.start = now

        let timeEntries = EntityCollection(unselectedTimeEntries)

        let state = CalendarDayState(
            user: .nothing,
            selectedDate: now,
            timeEntries: timeEntries,
            calendarEvents: [:],
            selectedItem: .left(editableTimeEntry)
        )

        let time: Time = Time(getNow: { now })
        let selectedTimeEntries = calendarItemsSelector(state, time)

        XCTAssertEqual(selectedTimeEntries.count, unselectedTimeEntries.count + 1)
        selectedTimeEntries.forEach {
            if case .timeEntry(_) = $0.value {
                XCTAssertEqual($0.description, "Expected")
            }
        }
    }

    private func createTimeEntry(id: Int64, start: Date, duration: TimeInterval, description: String) -> TimeEntry {
        TimeEntry(id: id, description: description, start: start, duration: duration, billable: false, workspaceId: 0)
    }
}
