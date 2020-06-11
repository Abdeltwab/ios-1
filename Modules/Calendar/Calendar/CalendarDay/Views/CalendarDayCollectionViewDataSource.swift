import UIKit
import RxDataSources
import OtherServices
import Utils

struct CalendarItemsSingleSection: AnimatableSectionModelType {

    var identity: Int = 0
    var items: [CalendarItem]

    var selectedItem: CalendarItem? {
        // Replace this implementation later when the selected item is included in the calendar items selector
        return nil
    }

    init(items: [CalendarItem]) {
        self.items = items
    }

    init(original: CalendarItemsSingleSection, items: [CalendarItem]) {
        self = original
        self.items = items
    }
}

// swiftlint:disable line_length
class CalendarDayCollectionViewDataSource: RxCollectionViewSectionedAnimatedDataSource<CalendarItemsSingleSection>, CalendarDayCollectionViewLayoutDelegate {
// swiftlint:enable line_length

    let time: Time

    // swiftlint:disable function_body_length
    init(time: Time) {
        self.time = time
        super.init(
            configureCell: { _, collectionView, indexPath, calendarItem in
                let reuseIdentifier = CalendarItemCollectionViewCell.reuseIdentifier
                guard let cell = collectionView
                    .dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CalendarItemCollectionViewCell
                    else { fatalError("Failed to dequeue cell with identifier: \(reuseIdentifier)") }
                cell.configure(with: calendarItem)
                return cell
            },
            configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
                switch kind {
                case CalendarDayCollectionViewLayout.SupplementaryViews.hourIndicatorKind:
                    let reuseIdentifier = HourIndicatorSupplementaryView.reuseIdentifier
                    guard let cell = collectionView
                        .dequeueReusableSupplementaryView(ofKind: CalendarDayCollectionViewLayout.SupplementaryViews.hourIndicatorKind,
                                                          withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? HourIndicatorSupplementaryView
                        else { fatalError("Failed to dequeue cell with identifier: \(reuseIdentifier)") }

                    let hour = indexPath.row
                    let date = time.now().ignoreTimeComponents().addingTimeInterval(TimeInterval(hour * Int.secondsInAnHour))
                    cell.hourIndicatorLabel.text = date.toTimeString()
                    return cell

                case CalendarDayCollectionViewLayout.SupplementaryViews.editingHourIndicatorKind:
                    let reuseIdentifier = EditingHourIndicatorSupplementaryView.reuseIdentifier
                    guard let cell = collectionView
                        .dequeueReusableSupplementaryView(ofKind: CalendarDayCollectionViewLayout.SupplementaryViews.editingHourIndicatorKind,
                                                          withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? EditingHourIndicatorSupplementaryView
                        else { fatalError("Failed to dequeue cell with identifier: \(reuseIdentifier)") }

                    if let selectedItem = dataSource.sectionModels[0].selectedItem {
                        let date = indexPath.item == 0 ? selectedItem.start : selectedItem.stop
                        cell.hourIndicatorLabel.text = date.toTimeString()
                        cell.hourIndicatorLabel.isHidden = false
                    } else {
                        cell.hourIndicatorLabel.isHidden = true
                    }
                    return cell

                case CalendarDayCollectionViewLayout.SupplementaryViews.currentTimeKind:
                    let reuseIdentifier = CurrentTimeSupplementaryView.reuseIdentifier
                    guard let cell = collectionView
                        .dequeueReusableSupplementaryView(ofKind: CalendarDayCollectionViewLayout.SupplementaryViews.currentTimeKind,
                                                          withReuseIdentifier: reuseIdentifier,
                                                          for: indexPath) as? CurrentTimeSupplementaryView
                        else { fatalError("Failed to dequeue cell with identifier: \(reuseIdentifier)") }
                    return cell
                    
                default:
                    fatalError("Failed to dequeue reusable view for supplementary view of kind: \(kind)")
                }
            }
        )
    }
    // swiftlint:enable function_body_length

    func calendarItem(at indexPath: IndexPath) -> CalendarItem? {
        guard let section = self.sectionModels.first else { return nil }
        return section.items[indexPath.item]
    }
}
