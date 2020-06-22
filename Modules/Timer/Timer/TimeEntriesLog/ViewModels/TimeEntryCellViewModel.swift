import UIKit
import Models

enum TimeEntryCellViewModel: Equatable {
    
    public static func == (lhs: TimeEntryCellViewModel, rhs: TimeEntryCellViewModel) -> Bool {
        switch (lhs, rhs) {
        case (let .singleEntry(lEntry, lInGroup), let .singleEntry(rEntry, rInGroup)):
            return lEntry == rEntry && lInGroup == rInGroup
        case (let .groupedEntriesHeader(lEntries, lOpen), let .groupedEntriesHeader(rEntries, rOpen)):
            return lEntries == rEntries && lOpen == rOpen
        default:
            return false
        }
    }
    
    case singleEntry(TimeEntryViewModel, inGroup: Bool)
    case groupedEntriesHeader([TimeEntryViewModel], open: Bool)
    
    private var sample: TimeEntryViewModel {
        
        switch self {
        case let .singleEntry(timeEntryViewModel, _):
            return timeEntryViewModel
        case let .groupedEntriesHeader(timeEntryViewModels, _):
            return timeEntryViewModels.first!
        }
    }
    
    var description: String {
        return sample.description
    }
    
    var durationString: String? {
        switch self {
        case let .singleEntry(timeEntryViewModel, _):
            return timeEntryViewModel.durationString
        case let .groupedEntriesHeader(timeEntryViewModels, _):
            return timeEntryViewModels.map { $0.duration ?? 0 }
                .reduce(0, +)
                .formattedDuration()
        }
    }
    
    var isInGroup: Bool {
        if case let .singleEntry(_, inGroup) = self, inGroup == true {
            return true
        }
    
        return false
    }
    
    var isGroupHeader: Bool {
        if case .groupedEntriesHeader = self {
            return true
        }
    
        return false
    }
    
    var duration: TimeInterval? {
        switch self {
        case let .singleEntry(timeEntryViewModel, _):
            return timeEntryViewModel.duration
        case let .groupedEntriesHeader(timeEntryViewModels, _):
            return timeEntryViewModels.map { $0.duration ?? 0 }
                .reduce(0, +)
        }
    }
    
    var projectTaskClient: NSAttributedString {
        return sample.projectTaskClient
    }
    
    var descriptionColor: UIColor {
        return sample.descriptionColor
    }
    
    var projectColor: UIColor {
        return sample.projectColor
    }
    
    var billable: Bool {
        return sample.billable
    }
    
    var tags: [Tag]? {
        return sample.tags
    }
    
    var start: Date {
        return sample.start
    }
    
    var mainEntryId: Int64 {
        return sample.id
    }
    
    var id: String {
        switch self {
        case .groupedEntriesHeader:
            return "G:\(sample.id)"
        case .singleEntry:
            return "S:\(sample.id)"
        }
    }
    
    var allIds: [Int64] {
        switch self {
        case let .groupedEntriesHeader(timeEntries, _ ):
            return timeEntries.map { $0.id }
        case let .singleEntry(timeEntry, _):
            return [timeEntry.id]
        }
    }
}
