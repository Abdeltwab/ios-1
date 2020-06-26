import Models
import OtherServices
import Utils

final class CalendarLayoutCalculator {

    typealias CalendarItemGroup = [CalendarItem.Value]
    typealias CalendarItemGroups = [CalendarItemGroup]

    private let offsetFromNow: TimeInterval = 7 * .secondsInAMinute
    private let minimumDurationForUIPurposes: TimeInterval = 15 * .secondsInAMinute
    private let time: Time
    private let entities: TimeLogEntities

    init(time: Time, entities: TimeLogEntities) {
        self.time = time
        self.entities = entities
    }

    func calculateLayoutAttributesforItems(calendarItems: [CalendarItem.Value]) -> [CalendarItem] {
        guard !calendarItems.isEmpty else { return [] }

        return calendarItems
            .sorted(by: { $0.start < $1.start })
            .reduce(into: [], groupOverlappingItems)
            .flatMap(calculateLayoutAttributesForGroup)
    }

    private func groupOverlappingItems(groups: inout CalendarItemGroups, calendarItem: CalendarItem.Value) {
        if groups.isEmpty {
            groups.append([calendarItem])
            return
        }

        guard var group = groups.last else { return }
        guard let maxStopTime = group.map(stopTime(for:)).max() else { return }
        if calendarItem.start < maxStopTime {
            group.append(calendarItem)
            groups[groups.count - 1] = group
        } else {
            groups.append([calendarItem])
        }
    }

    private func calculateLayoutAttributesForGroup(group: CalendarItemGroup) -> [CalendarItem] {
        let left = group.filter({
            if case .calendarEvent(_) = $0 {
                return true
            }
            return false
        })
        let right = group.filter({
            switch $0 {
            case .timeEntry, .selectedItem:
                return true
            default: return false
            }
        })

        let leftColumns = left.reduce(into: [], intoColumns)
        let rightColumns = right.reduce(into: [], intoColumns)

        let groups = leftColumns + rightColumns

        let layoutAttributes: [[CalendarItem]] = groups.enumerated().map({ enumeratedElement in
            let group = enumeratedElement.element
            let columnIndex = enumeratedElement.offset
            return group.map({ self.attributes(for: $0, columnIndex: columnIndex, totalColumns: groups.count) })
        })
        return layoutAttributes.flatMap({ $0 })
    }

    private func intoColumns(groups: inout CalendarItemGroups, calendarItem: CalendarItem.Value) {
        if groups.isEmpty {
            groups.append([calendarItem])
            return
        }

        var positionToInsert = -1
        let columnToInsertIndex = groups.firstIndex(where: { group in
            guard let index = group.lastIndex(where: { stopTime(for: $0) <= calendarItem.start }) else { return false }
            if index == group.count - 1 {
                positionToInsert = group.count
                return true
            }
            if group[index + 1].start >= stopTime(for: calendarItem) {
                positionToInsert += 1
                return true
            }
            return false
        })

        if let columnToInsertIndex = columnToInsertIndex {
            assert(0..<groups.count ~= columnToInsertIndex, "Group index is out of range")
            assert(positionToInsert >= 0, "Position to insert item must be greater or equal to zero")
            var group = groups[columnToInsertIndex]
            group.insert(calendarItem, at: positionToInsert)
            groups[columnToInsertIndex] = group
        } else {
            groups.append([calendarItem])
        }
    }

    private func stopTime(for item: CalendarItem.Value) -> Date {
        if let duration = item.duration {
            return duration < minimumDurationForUIPurposes ? item.start + minimumDurationForUIPurposes : item.start + duration
        } else {
            return time.now() + offsetFromNow
        }
    }

    private func duration(for item: CalendarItem.Value) -> TimeInterval {
        return item.duration ?? time.now().timeIntervalSince(item.start) + offsetFromNow
    }

    private func durationForUIPurposes(for item: CalendarItem.Value) -> TimeInterval {
        let actualDuration = duration(for: item)
        return actualDuration < minimumDurationForUIPurposes ? minimumDurationForUIPurposes : actualDuration
    }

    private func attributes(for value: CalendarItem.Value, columnIndex: Int, totalColumns: Int) -> CalendarItem {
        return CalendarItem(
            value: value,
            columnIndex: columnIndex,
            totalColumns: totalColumns,
            projectOrCalendar: projectOrCalendar(for: value),
            color: color(for: value),
            duration: durationForUIPurposes(for: value)
        )
    }

    private func color(for value: CalendarItem.Value) -> String? {
        switch value {
        case .calendarEvent(let calendarEvent):
            return calendarEvent.color
        case .selectedItem(let selectedItem):
            switch selectedItem {
            case .left(let editableTimeEntry):
                guard let projectId = editableTimeEntry.projectId else { return nil }
                guard let project = entities.getProject(projectId) else { return nil }
                return project.color
            case .right(let calendarEvent):
                return calendarEvent.calendarName
            }
        case .timeEntry(let timeEntry):
            guard let projectId = timeEntry.projectId else { return nil }
            guard let project = entities.getProject(projectId) else { return nil }
            return project.color
        }
    }

    private func projectOrCalendar(for value: CalendarItem.Value) -> String? {
        switch value {
        case .calendarEvent(let calendarEvent):
            return calendarEvent.calendarName
        case .selectedItem(let selectedItem):
            switch selectedItem {
            case .left(let editableTimeEntry):
                guard let projectId = editableTimeEntry.projectId else { return nil }
                guard let project = entities.getProject(projectId) else { return nil }
                return project.name
            case .right(let calendarEvent):
                return calendarEvent.calendarName
            }
        case .timeEntry(let timeEntry):
            guard let projectId = timeEntry.projectId else { return nil }
            guard let project = entities.getProject(projectId) else { return nil }
            return project.name
        }
    }
}
