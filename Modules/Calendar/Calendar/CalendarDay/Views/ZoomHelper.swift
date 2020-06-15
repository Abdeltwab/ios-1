import UIKit

class ZoomHelper: NSObject {

    unowned var collectionView: UICollectionView!
    unowned var layout: CalendarDayCollectionViewLayout!
    private var gestureRecognizer: UIPinchGestureRecognizer!

    init(collectionView: UICollectionView, layout: CalendarDayCollectionViewLayout) {
        super.init()
        self.collectionView = collectionView
        self.layout = layout
        self.gestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(onGesture(_:)))
        collectionView.addGestureRecognizer(self.gestureRecognizer)
    }

    @objc
    func onGesture(_ gesture: UIPinchGestureRecognizer) {
        let pinchCenter = gesture.location(in: collectionView)
        switch gesture.state {
        case .began, .changed, .ended:
            layout.setScale(gesture.scale, center: pinchCenter)
        default: break
        }
    }
}
