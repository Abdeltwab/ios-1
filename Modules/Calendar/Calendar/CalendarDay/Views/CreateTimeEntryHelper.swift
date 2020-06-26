import UIKit

class CreateTimeEntryHelper: AutoScrollHelper, UIGestureRecognizerDelegate {

    private unowned var store: CalendarDayStore!

    private var gestureRecognizer: UILongPressGestureRecognizer!

    init(collectionView: UICollectionView,
         dataSource: CalendarDayCollectionViewDataSource,
         layout: CalendarDayCollectionViewLayout,
         store: CalendarDayStore
    ) {
        super.init(collectionView: collectionView, dataSource: dataSource, layout: layout)
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
            gestureChanged(at: point)
        default:
            firstPoint = nil
            previousPoint = nil
            currentPoint = nil
            stopAutoScroll()
        }
    }

    private func gestureChanged(at point: CGPoint) {
        let timeInterval = layout.timeInterval(at: point)
        currentPoint = point
        if isScrollingUp && point.y < topAutoScrollLine {
            startAutoScrollUp()
        } else if isScrollingDown && point.y > bottomAutoScrollLine {
            startAutoScrollDown()
        } else {
            stopAutoScroll()
        }
        store.dispatch(.timeEntryDragged(timeInterval))
    }

    override func update(point: CGPoint) {
        self.gestureChanged(at: point)
    }
}
