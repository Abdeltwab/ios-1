import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models
import OtherServices

public typealias CalendarDayStore = Store<CalendarDayState, CalendarDayAction>

public class CalendarDayViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Calendar"
    public static var storyboardBundle = Assets.bundle

    @IBOutlet var collectionView: UICollectionView!
    private var dataSource: CalendarDayCollectionViewDataSource!
    private var layout: CalendarDayCollectionViewLayout!
    private var createTimeEntryHelper: CreateTimeEntryHelper!

    private var disposeBag = DisposeBag()

    public var store: CalendarDayStore!
    public var time: Time!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Configure collectionView

        collectionView.register(CalendarItemCollectionViewCell.nib,
                                forCellWithReuseIdentifier: CalendarItemCollectionViewCell.reuseIdentifier)
        collectionView.register(HourIndicatorSupplementaryView.nib,
                                forSupplementaryViewOfKind: CalendarDayCollectionViewLayout.SupplementaryViews.hourIndicatorKind,
                                withReuseIdentifier: HourIndicatorSupplementaryView.reuseIdentifier)
        collectionView.register(EditingHourIndicatorSupplementaryView.nib,
                                forSupplementaryViewOfKind: CalendarDayCollectionViewLayout.SupplementaryViews.editingHourIndicatorKind,
                                withReuseIdentifier: EditingHourIndicatorSupplementaryView.reuseIdentifier)
        collectionView.register(CurrentTimeSupplementaryView.nib,
                                forSupplementaryViewOfKind: CalendarDayCollectionViewLayout.SupplementaryViews.currentTimeKind,
                                withReuseIdentifier: CurrentTimeSupplementaryView.reuseIdentifier)

        dataSource = CalendarDayCollectionViewDataSource(time: time)
        layout = CalendarDayCollectionViewLayout(time: time)
        layout.delegate = dataSource
        collectionView.setCollectionViewLayout(layout, animated: false)
        createTimeEntryHelper = CreateTimeEntryHelper(collectionView: collectionView,
                                                      dataSource: dataSource,
                                                      layout: layout,
                                                      store: store)

        store.select({ calendarItemsSelector($0, self.time) })
            .mapTo({ [CalendarItemsSingleSection(items: $0)] })
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}
