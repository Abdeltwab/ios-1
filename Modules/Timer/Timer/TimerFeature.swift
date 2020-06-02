import Foundation
import Architecture
import Repository
import OtherServices
import CommonFeatures

public func createTimerReducer(repository: Repository, time: Time, schedulerProvider: SchedulerProvider) -> Reducer<TimerState, TimerAction> {

    let timeEntriesCoreReducer = createTimeEntriesReducer(time: time, repository: repository)

    return combine(
        createTimeEntriesLogReducer(repository: repository, time: time, schedulerProvider: schedulerProvider)
            .decorate(with: timeEntriesCoreReducer, state: \.entities.timeEntries, action: \.timeEntries)
            .pullback(state: \.timeLogState, action: \.timeLog),
        createStartEditReducer(repository: repository, time: time)
            .decorate(with: timeEntriesCoreReducer, state: \.entities.timeEntries, action: \.timeEntries)
            .pullback(state: \.startEditState, action: \.startEdit),
        createRunningTimeEntryReducer(repository: repository, time: time)
            .decorate(with: timeEntriesCoreReducer, state: \.entities.timeEntries, action: \.timeEntries)
            .pullback(state: \.runningTimeEntryState, action: \.runningTimeEntry),
        createProjectReducer(repository: repository)
            .pullback(state: \.projectState, action: \.project)
    )
}

public class TimerFeature: BaseFeature<TimerState, TimerAction> {

    private enum Features {
        case timeEntriesLog
        case startEdit
        case runningTimeEntry
        case project
    }

    private let time: Time
    private let features: [Features: BaseFeature<TimerState, TimerAction>]

    public init(time: Time) {
        self.time = time

        features = [
               .timeEntriesLog: TimeEntriesLogFeature()
                   .view { $0.view(
                       state: { $0.timeLogState },
                       action: { TimerAction.timeLog($0) })
               },
               .startEdit: StartEditFeature(time: time)
                   .view { $0.view(
                       state: { $0.startEditState },
                       action: { TimerAction.startEdit($0) })
               },
               .runningTimeEntry: RunningTimeEntryFeature()
                   .view { $0.view(
                       state: { $0.runningTimeEntryState },
                       action: { TimerAction.runningTimeEntry($0) })
               },
               .project: ProjectFeature()
                   .view { $0.view(
                       state: { $0.projectState },
                       action: { TimerAction.project($0) })
               }
           ]
    }

    // swiftlint:disable force_cast
    public override func mainCoordinator(store: Store<TimerState, TimerAction>) -> Coordinator {
        return TimerCoordinator(
            store: store,
            timeLogCoordinator: features[.timeEntriesLog]!.mainCoordinator(store: store) as! TimeEntriesLogCoordinator,
            startEditCoordinator: features[.startEdit]!.mainCoordinator(store: store) as! StartEditCoordinator,
            runningTimeEntryCoordinator: features[.runningTimeEntry]!.mainCoordinator(store: store) as! RunningTimeEntryCoordinator,
            projectCoordinator: features[.project]!.mainCoordinator(store: store) as! ProjectCoordinator
        )
    }
    // swiftlint:enable force_cast
}

public struct TimerConstants {
    static let timeEntryDeletionDelaySeconds: Int = 5
    static let maxTimeEntryDurationInHours: Int = 999
}
