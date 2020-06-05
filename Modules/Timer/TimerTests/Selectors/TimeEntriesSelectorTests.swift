// swiftlint:disable file_length
import XCTest
@testable import Timer
import Models

// swiftlint:disable type_body_length
class TimeEntriesSelectorTests: XCTestCase {

    private static var now: Date = {
        var calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2019, month: 02, day: 07, hour: 16, minute: 25, second: 38)
        return calendar.date(from: components)!
    }()

    private static let workspaceA: Workspace = Workspace(id: 1, name: "", admin: true)
    private static let workspaceB: Workspace = Workspace(id: 2, name: "", admin: true)

    private let entriesPendingDeletion = Set<Int64>(arrayLiteral: 10, 20, 30, 40, 50)

    private let singleItemGroup = [
        TimeEntry.with(description: "S", start: now.addingTimeInterval(-110), duration: 1, workspaceId: workspaceA.id)
    ]

    private let groupA = [
        TimeEntry.with(description: "A", start: now, duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(description: "A", start: now.addingTimeInterval(-50), duration: 2, workspaceId: workspaceA.id),
        TimeEntry.with(description: "A", start: now.addingTimeInterval(-100), duration: 4, workspaceId: workspaceA.id)
    ]

    private let groupB = [
        TimeEntry.with(description: "B", start: now.addingTimeInterval(-200), duration: 1, workspaceId: workspaceB.id),
        TimeEntry.with(description: "B", start: now.addingTimeInterval(-250), duration: 2, workspaceId: workspaceB.id),
        TimeEntry.with(description: "B", start: now.addingTimeInterval(-300), duration: 4, workspaceId: workspaceB.id)
    ]

    private let twoWorkspaces = [
        TimeEntry.with(description: "B", start: now, duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(description: "B", start: now.addingTimeInterval(50), duration: 2, workspaceId: workspaceB.id)
    ]

    private let differentDescriptions = [
        TimeEntry.with(description: "C1", start: now, duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(description: "C1", start: now.addingTimeInterval(-50), duration: 2, workspaceId: workspaceA.id),
        TimeEntry.with(description: "C2", start: now.addingTimeInterval(-100), duration: 4, workspaceId: workspaceA.id)
    ]

    private let longDuration = [
        TimeEntry.with(description: "D1", start: now, duration: 1.5 * 3600, workspaceId: workspaceA.id),
        TimeEntry.with(description: "D1", start: now.addingTimeInterval(-50), duration: 2.5 * 3600, workspaceId: workspaceA.id),
        TimeEntry.with(description: "D2", start: now.addingTimeInterval(-100), duration: 3.5 * 3600, workspaceId: workspaceA.id)
    ]

    private let singleDeletedGroup = [
        TimeEntry.with(id: 10, description: "S2", start: now.addingTimeInterval(-110), duration: 1, workspaceId: workspaceA.id)
    ]

    private let deletedGroup = [
        TimeEntry.with(id: 20, description: "E", start: now, duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(id: 30, description: "E", start: now.addingTimeInterval(-50), duration: 2, workspaceId: workspaceA.id)
    ]

    private let groupWithDeletedEntries1 = [
        TimeEntry.with(description: "F", start: now.addingTimeInterval(-200), duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(description: "F", start: now.addingTimeInterval(-210), duration: 2, workspaceId: workspaceA.id),
        TimeEntry.with(description: "F", start: now.addingTimeInterval(-220), duration: 4, workspaceId: workspaceA.id),
        TimeEntry.with(id: 40, description: "F", start: now.addingTimeInterval(-230), duration: 4, workspaceId: workspaceA.id)
    ]

    private let groupWithDeletedEntries2 = [
        TimeEntry.with(id: 50, description: "G", start: now.addingTimeInterval(-240), duration: 4, workspaceId: workspaceA.id),
        TimeEntry.with(description: "G", start: now.addingTimeInterval(-250), duration: 1, workspaceId: workspaceA.id),
        TimeEntry.with(description: "G", start: now.addingTimeInterval(-260), duration: 2, workspaceId: workspaceA.id),
        TimeEntry.with(description: "G", start: now.addingTimeInterval(-270), duration: 4, workspaceId: workspaceA.id)
    ]

    private var state: TimeEntriesLogState!

    override func setUp() {
        state = TimeEntriesLogState(entities: TimeLogEntities(), expandedGroups: [], entriesPendingDeletion: entriesPendingDeletion)
        state.entities.workspaces = EntityCollection([
            TimeEntriesSelectorTests.workspaceA,
            TimeEntriesSelectorTests.workspaceB
        ])
    }

    // swiftlint:disable function_body_length
    func testTransformsTimeEntriesIntoACorrectTree() {

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: [],
            entriesPendingDeletion: [],
            timeEntries: groupA,
            expected: [
                logOf(collapsed(groupA))
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA),
            entriesPendingDeletion: [],
            timeEntries: groupA,
            expected: [
                logOf(expanded(groupA))
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA),
            entriesPendingDeletion: [],
            timeEntries: groupA + groupB,
            expected: [
                logOf(expanded(groupA) + collapsed(groupB))
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupB),
            entriesPendingDeletion: [],
            timeEntries: singleItemGroup,
            expected: [
                logOf(single(singleItemGroup.first!))
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: [],
            timeEntries: groupA + singleItemGroup + groupB,
            expected: [
                logOf(
                    collapsed(groupA)
                        + single(singleItemGroup.first!)
                        + collapsed(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA),
            entriesPendingDeletion: [],
            timeEntries: groupA + singleItemGroup + groupB,
            expected: [
                logOf(
                    expanded(groupA)
                        + single(singleItemGroup.first!)
                        + collapsed(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupB),
            entriesPendingDeletion: [],
            timeEntries: groupA + singleItemGroup + groupB,
            expected: [
                logOf(
                    collapsed(groupA)
                        + single(singleItemGroup.first!)
                        + expanded(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + singleItemGroup + singleDeletedGroup + groupB,
            expected: [
                logOf(
                    collapsed(groupA)
                        + single(singleItemGroup.first!)
                        + collapsed(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + singleItemGroup + singleDeletedGroup + groupB,
            expected: [
                logOf(
                    expanded(groupA)
                        + single(singleItemGroup.first!)
                        + collapsed(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupB),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + singleItemGroup + singleDeletedGroup + groupB,
            expected: [
                logOf(
                    collapsed(groupA)
                        + single(singleItemGroup.first!)
                        + expanded(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA, groupB),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + singleItemGroup + singleDeletedGroup + groupB,
            expected: [
                logOf(
                    expanded(groupA)
                        + single(singleItemGroup.first!)
                        + expanded(groupB)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupWithDeletedEntries1,
            expected: [
                logOf(
                    collapsed(groupWithDeletedEntries1, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupWithDeletedEntries2,
            expected: [
                logOf(
                    collapsed(groupWithDeletedEntries2, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupWithDeletedEntries1),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupWithDeletedEntries1,
            expected: [
                logOf(
                    expanded(groupWithDeletedEntries1, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupWithDeletedEntries2),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupWithDeletedEntries2,
            expected: [
                logOf(
                    expanded(groupWithDeletedEntries2, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA, groupWithDeletedEntries1),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + groupWithDeletedEntries1,
            expected: [
                logOf(
                    expanded(groupA)
                        + expanded(groupWithDeletedEntries1, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(groupA, groupWithDeletedEntries2),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: groupA + groupWithDeletedEntries2,
            expected: [
                logOf(
                    expanded(groupA)
                         + expanded(groupWithDeletedEntries2, excludedTimeEntryIds: entriesPendingDeletion)
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: singleDeletedGroup,
            expected: []
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: deletedGroup,
            expected: []
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: twoWorkspaces,
            expected: [
                logOf(
                    single(twoWorkspaces[0])
                        + single(twoWorkspaces[1])
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: differentDescriptions,
            expected: [
                logOf(
                    collapsed(Array(differentDescriptions.prefix(2)))
                    + single(differentDescriptions[2])
                )
            ]
        )

        assertTransformsTimeEntriesIntoACorrectTree(
            expandedGroups: expandedGroups(),
            entriesPendingDeletion: entriesPendingDeletion,
            timeEntries: longDuration,
            expected: [
                logOf(
                    collapsed(Array(longDuration.prefix(2)))
                    + single(longDuration[2])
                )
            ]
        )
    }

    private func assertTransformsTimeEntriesIntoACorrectTree(
        expandedGroups: Set<Int>,
        entriesPendingDeletion: Set<Int64>,
        timeEntries: [TimeEntry],
        expected: [DayViewModel],
        file: StaticString = #file,
        line: UInt = #line) {

        state.entities.timeEntries = EntityCollection(timeEntries)
        state.expandedGroups = expandedGroups
        state.entriesPendingDeletion = entriesPendingDeletion

        let expandedGroups = expandedGroupsSelector(state)
        let timeEntryViewModels = timeEntryViewModelsSelector(state)
        let result = toDaysMapper(timeEntryViewModels, expandedGroups, entriesPendingDeletion)

        XCTAssertEqual(result, expected, file: file, line: line)
    }

    private func expandedGroups(_ timeEntryGroups: [TimeEntry]...) -> Set<Int> {
        return Set(timeEntryGroups.map {
            return TimeEntryViewModel(timeEntry: $0.first!).groupId
        })
    }

    private func logOf(_ logCellViewModels: [TimeLogCellViewModel]) -> DayViewModel {
        return DayViewModel(timeLogCells: logCellViewModels.sorted(by: { $0.start > $1.start }))
    }

    private func single(_ timeEntry: TimeEntry, excludedTimeEntryIds: Set<Int64> = []) -> [TimeLogCellViewModel] {
        guard !excludedTimeEntryIds.contains(timeEntry.id) else { return [] }
        let timeEntryViewModel = TimeEntryViewModel(timeEntry: timeEntry)
        return [TimeLogCellViewModel.singleEntry(timeEntryViewModel, inGroup: false)]
    }

    private func collapsed(_ timeEntries: [TimeEntry], excludedTimeEntryIds: Set<Int64> = []) -> [TimeLogCellViewModel] {
        let timeEntreViewModels = timeEntries
            .filter({ !excludedTimeEntryIds.contains($0.id) })
            .map {
                TimeEntryViewModel(timeEntry: $0)
            }
            .sorted(by: { $0.start > $1.start })

        return [TimeLogCellViewModel.groupedEntriesHeader(timeEntreViewModels, open: false)]
    }

    private func expanded(_ timeEntries: [TimeEntry], excludedTimeEntryIds: Set<Int64> = []) -> [TimeLogCellViewModel] {
        let timeEntreViewModels = timeEntries
            .filter({ !excludedTimeEntryIds.contains($0.id) })
            .map {
                TimeEntryViewModel(timeEntry: $0)
            }
            .sorted(by: { $0.start > $1.start })

        return [TimeLogCellViewModel.groupedEntriesHeader(timeEntreViewModels, open: true)]
            + timeEntreViewModels.map {
                TimeLogCellViewModel.singleEntry($0, inGroup: true)
            }
    }
}

extension DayViewModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(dayString), duration: \(durationString), entries: \(items)"
    }
}

extension TimeLogCellViewModel: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\(description): \(start)"
    }
}
