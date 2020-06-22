import Foundation
import Utils
import RxSwift
import RxCocoa

struct DayViewModel: Equatable {
    
    public static func == (lhs: DayViewModel, rhs: DayViewModel) -> Bool {
        return lhs.durationString == rhs.durationString && lhs.dayString == rhs.dayString && lhs.timeLogCells == rhs.timeLogCells
    }
    
    let day: Date
    let dayString: String
    let durationString: String
    
    var timeLogCells: [TimeEntriesLogCellViewModel]
        
    init(timeLogCells: [TimeEntriesLogCellViewModel]) {
        
        let cellViewModels = timeLogCells.compactMap({ cellViewModel -> TimeEntryCellViewModel? in
                if case let TimeEntriesLogCellViewModel.timeEntryCell(timeEntryCellViewModel) = cellViewModel {
                    return timeEntryCellViewModel
                } else {
                    return nil
                }
            })
        
        day = cellViewModels.first!.start.ignoreTimeComponents()
        dayString = day.toDayString()
        self.timeLogCells = timeLogCells
        
        durationString = cellViewModels
            .filter({ !$0.isInGroup })
            .map({ $0.duration ?? 0 })
            .reduce(0, +)
            .formattedDuration()

    }
}
