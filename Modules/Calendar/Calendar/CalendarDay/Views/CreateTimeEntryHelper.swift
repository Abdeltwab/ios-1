import UIKit

class CreateTimeEntryHelper: NSObject, UIGestureRecognizerDelegate {

    private unowned var collectionView: UICollectionView!
    private unowned var dataSource: CalendarDayCollectionViewDataSource!
    private unowned var layout: CalendarDayCollectionViewLayout!
    private unowned var store: CalendarDayStore!

    private var gestureRecognizer: UILongPressGestureRecognizer!

    init(collectionView: UICollectionView,
         dataSource: CalendarDayCollectionViewDataSource,
         layout: CalendarDayCollectionViewLayout,
         store: CalendarDayStore
    ) {
        super.init()

        self.collectionView = collectionView
        self.dataSource = dataSource
        self.layout = layout
        self.store = store

        self.gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onGesture(_:)))
        gestureRecognizer.delegate = self

        self.collectionView.addGestureRecognizer(self.gestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.gestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.gestureRecognizer {
            let point = touch.location(in: collectionView)
            return collectionView.indexPathForItem(at: point) == nil
        }
        return true
    }

    @objc
    func onGesture(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        let timeInterval = layout.timeInterval(at: point)
        switch gesture.state {
        case .began:
            store.dispatch(.emptyPositionLongPressed(timeInterval))
        case .changed:
            store.dispatch(.timeEntryDragged(timeInterval))
        default:
            break
        }
    }
}
