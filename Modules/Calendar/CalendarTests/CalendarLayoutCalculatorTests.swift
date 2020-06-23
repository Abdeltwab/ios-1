import CalendarService
import Models
import OtherServices
import Utils
import XCTest
@testable import Calendar

class CalendarLayoutCalculatorTests: XCTestCase {

    func test_whenCalendarItemsDoNotOverlap() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 30 * .secondsInAMinute),
            timeEntry(id: 2, description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 30 * .secondsInAMinute),
            timeEntry(id: 3, description: "Item 3", start: Date.with(2018, 11, 21, 10, 0, 0, .utc), duration: 30 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 1)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 1)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[1].start)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 1)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[2].start)
    }

    func test_whenTwoItemsOverlap() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 2, description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 30 * .secondsInAMinute),
            timeEntry(id: 3, description: "Item 3", start: Date.with(2018, 11, 21, 10, 0, 0, .utc), duration: 30 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[1].start)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 1)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[2].start)
    }

    func test_whenTwoItemsShouldOverlapBecauseOfMinimumDuration() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 10),
            timeEntry(id: 2, description: "Item 2", start: Date.with(2018, 11, 21, 8, 0, 11, .utc), duration: 10)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 2)
    }

    func test_whenThreeItemsOverlapButOnlyTwoColumnsAreRequired() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 2, description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 3, description: "Item 3", start: Date.with(2018, 11, 21, 10, 0, 0, .utc), duration: 30 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[2].start)
        XCTAssertEqual(layoutAttributes[2].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[1].start)
    }

    func test_whenItemsOverlapInTwoDifferentGroupsWithDifferentNumberOfColumns() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 2, description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 3, description: "Item 3", start: Date.with(2018, 11, 21, 10, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 4, description: "Item 4", start: Date.with(2018, 11, 21, 14, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            timeEntry(id: 5, description: "Item 5", start: Date.with(2018, 11, 21, 15, 0, 0, .utc), duration: 90 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[2].start)
        XCTAssertEqual(layoutAttributes[2].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[1].start)
        XCTAssertEqual(layoutAttributes[3].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[3].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[3].start, calendarItems[3].start)
        XCTAssertEqual(layoutAttributes[4].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[4].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[4].start, calendarItems[4].start)
    }

    func test_calendarEventsHaveTheirOwnColumnsToTheLeft() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 90 * .secondsInAMinute),
            calendarEvent(id: "2", description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 60 * .secondsInAMinute),
            timeEntry(id: 3, description: "Item 3", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 30 * .secondsInAMinute),
            timeEntry(id: 4, description: "Item 4", start: Date.with(2018, 11, 21, 11, 0, 0, .utc), duration: 120 * .secondsInAMinute),
            calendarEvent(id: "5", description: "Item 5", start: Date.with(2018, 11, 21, 11, 0, 0, .utc), duration: 60 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[1].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[0].start)
        XCTAssertEqual(layoutAttributes[2].columnIndex, 2)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[2].start)
        XCTAssertEqual(layoutAttributes[3].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[3].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[3].start, calendarItems[4].start)
        XCTAssertEqual(layoutAttributes[4].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[4].totalColumns, 2)
        XCTAssertEqual(layoutAttributes[4].start, calendarItems[3].start)
    }

    func test_overlappingCalendarEventsAreAlwaysToTheLeft() {
        let calendarItems: [CalendarItem.Value] = [
            timeEntry(id: 1, description: "Item 1", start: Date.with(2018, 11, 21, 8, 0, 0, .utc), duration: 180 * .secondsInAMinute),
            calendarEvent(id: "2", description: "Item 2", start: Date.with(2018, 11, 21, 9, 0, 0, .utc), duration: 180 * .secondsInAMinute),
            calendarEvent(id: "5", description: "Item 5", start: Date.with(2018, 11, 21, 10, 0, 0, .utc), duration: 180 * .secondsInAMinute)]

        let now = Date()
        let time = Time(getNow: { now })

        let calculator = CalendarLayoutCalculator(time: time, entities: TimeLogEntities())

        let layoutAttributes = calculator.calculateLayoutAttributesforItems(calendarItems: calendarItems)

        XCTAssertEqual(layoutAttributes.count, calendarItems.count)
        XCTAssertEqual(layoutAttributes[0].columnIndex, 0)
        XCTAssertEqual(layoutAttributes[0].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[0].start, calendarItems[1].start)
        XCTAssertEqual(layoutAttributes[1].columnIndex, 1)
        XCTAssertEqual(layoutAttributes[1].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[1].start, calendarItems[2].start)
        XCTAssertEqual(layoutAttributes[2].columnIndex, 2)
        XCTAssertEqual(layoutAttributes[2].totalColumns, 3)
        XCTAssertEqual(layoutAttributes[2].start, calendarItems[0].start)
    }

    private func timeEntry(id: Int64, description: String, start: Date, duration: TimeInterval) -> CalendarItem.Value {
        .timeEntry(TimeEntry(id: id, description: description, start: start, duration: duration, billable: false, workspaceId: 0, tagIds: []))
    }

    private func calendarEvent(id: String, description: String, start: Date, duration: TimeInterval) -> CalendarItem.Value {
        .calendarEvent(CalendarEvent(id: id,
                                     calendarId: "",
                                     calendarName: "",
                                     description: description,
                                     start: start,
                                     stop: start + duration,
                                     color: ""))
    }
}
