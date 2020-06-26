import UIKit

class EditTimeEntryHelper: AutoScrollHelper, UIGestureRecognizerDelegate {
    
    private enum PanTarget {
        case start
        case stop
        case timeEntry
    }

    private unowned var store: CalendarDayStore!

    private var gestureRecognizer: UIPanGestureRecognizer!
    private var target: PanTarget?

    init(collectionView: UICollectionView,
         dataSource: CalendarDayCollectionViewDataSource,
         layout: CalendarDayCollectionViewLayout,
         store: CalendarDayStore
    ) {
        super.init(collectionView: collectionView, dataSource: dataSource, layout: layout)
        self.store = store

        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onGesture(_:)))
        gestureRecognizer.delegate = self

        self.collectionView.addGestureRecognizer(self.gestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer == self.gestureRecognizer else { return false }
        let point = touch.location(in: collectionView)
        return collectionView.visibleCells
            .compactMap { $0 as? CalendarItemCollectionViewCell }
            .contains { cell in
                cell.frame.contains(point)
                    || collectionView.convert(cell.topDragTouchArea, from: cell).contains(point)
                    || collectionView.convert(cell.bottomDragTouchArea, from: cell).contains(point)
            }
    }

    @objc
    func onGesture(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        switch gesture.state {
        case .began:
            gestureBegan(at: point)
        case .changed:
            gestureChanged(at: point)
        default:
            target = nil
            firstPoint = nil
            previousPoint = nil
            currentPoint = nil
            stopAutoScroll()
        }
    }
    
    private func gestureBegan(at point: CGPoint) {
        guard let indexPath = collectionView.indexPathForItem(at: point),
            let cell = collectionView.cellForItem(at: indexPath) as? CalendarItemCollectionViewCell else { return }
        if collectionView.convert(cell.topDragTouchArea, from: cell).contains(point) {
            target = .start
        } else if collectionView.convert(cell.bottomDragTouchArea, from: cell).contains(point) {
            target = .stop
        } else {
            target = .timeEntry
        }
        firstPoint = point
        dispathDragActions(at: point)
    }

    private func gestureChanged(at point: CGPoint) {
        guard target != nil else { return }
        currentPoint = point
        if isScrollingUp && point.y < topAutoScrollLine {
            startAutoScrollUp()
        } else if isScrollingDown && point.y > bottomAutoScrollLine {
            startAutoScrollDown()
        } else {
            stopAutoScroll()
        }
        dispathDragActions(at: point)
    }

    override func update(point: CGPoint) {
        self.gestureChanged(at: point)
    }
    
    private func dispathDragActions(at point: CGPoint) {
        guard let target = target else { return }
        let timeInterval = layout.timeInterval(at: point)
        switch target {
        case .start:
            store.dispatch(.startTimeDragged(timeInterval))
        case .stop:
            store.dispatch(.stopTimeDragged(timeInterval))
        case .timeEntry:
            store.dispatch(.timeEntryDragged(timeInterval))
        }
    }
}
