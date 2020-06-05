import UIKit
import RxDataSources

struct CalendarItemsSingleSection: AnimatableSectionModelType {

    var identity: Int = 0
    var items: [CalendarItem]

    init(items: [CalendarItem]) {
        self.items = items
    }

    init(original: CalendarItemsSingleSection, items: [CalendarItem]) {
        self = original
        self.items = items
    }
}

class CalendarDayCollectionViewDataSource: RxCollectionViewSectionedAnimatedDataSource<CalendarItemsSingleSection> {

    convenience init() {
        self.init(configureCell: { _, collectionView, indexPath, calendarItem in
            let reuseIdentifier = CalendarItemCollectionViewCell.reuseIdentifier
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CalendarItemCollectionViewCell
                else { fatalError("Failed to dequeue cell with identifier: \(reuseIdentifier)") }
            cell.configure(with: calendarItem)
            return cell
        })
    }
}
