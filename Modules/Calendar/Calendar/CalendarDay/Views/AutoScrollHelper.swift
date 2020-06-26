import UIKit
import Utils

class AutoScrollHelper: NSObject {

    unowned var collectionView: UICollectionView!
    unowned var dataSource: CalendarDayCollectionViewDataSource!
    unowned var layout: CalendarDayCollectionViewLayout!
    private var displayLink: CADisplayLink?

    private var autoScrollDistance: CGFloat!
    private let topAutoScrollZoneHeight: CGFloat = 50
    private let bottomAutoScrollZoneHeight: CGFloat = 288
    private let autoScrollsPerSecond = 8

    // MARK: Internal state
    private var scrollAmount: CGFloat = 0
    private var isAutoScrollingUp: Bool = false
    private var isAutoScrollingDown: Bool = false
    var firstPoint: CGPoint?
    var previousPoint: CGPoint?
    var currentPoint: CGPoint? {
        didSet {
            previousPoint = oldValue
        }
    }

    // MARK: Helpers
    private var shouldStopAutoScrollUp: Bool { isAutoScrollingUp && collectionView.isAtTop }
    private var shouldStopAutoScrollDown: Bool { isAutoScrollingDown && collectionView.isAtBottom }
    var topAutoScrollLine: CGFloat { collectionView.contentOffset.y + topAutoScrollZoneHeight }
    var bottomAutoScrollLine: CGFloat { collectionView.contentOffset.y + collectionView.frame.height - bottomAutoScrollZoneHeight }

    var isScrollingUp: Bool {
        guard let currentPoint = currentPoint, let previousPoint = previousPoint else { return false }
        return currentPoint.y <= previousPoint.y
    }
    var isScrollingDown: Bool {
        guard let currentPoint = currentPoint, let previousPoint = previousPoint else { return false }
        return currentPoint.y >= previousPoint.y
    }

    init(collectionView: UICollectionView, dataSource: CalendarDayCollectionViewDataSource, layout: CalendarDayCollectionViewLayout) {
        super.init()
        self.collectionView = collectionView
        self.dataSource = dataSource
        self.layout = layout
        self.autoScrollDistance = self.layout.hourHeight / 4
    }

    func startAutoScrollUp() {
        guard !isAutoScrollingUp else { return }
        isAutoScrollingUp = true
        isAutoScrollingDown = false
        self.scrollAmount = -autoScrollDistance - 10
        self.displayLink?.invalidate()
        self.displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLink))
        self.displayLink?.preferredFramesPerSecond = autoScrollsPerSecond
        self.displayLink?.add(to: .main, forMode: .default)
    }

    func startAutoScrollDown() {
        guard !isAutoScrollingDown else { return }
        isAutoScrollingUp = false
        isAutoScrollingDown = true
        self.scrollAmount = autoScrollDistance
        self.displayLink?.invalidate()
        self.displayLink = CADisplayLink(target: self, selector: #selector(onDisplayLink))
        self.displayLink?.preferredFramesPerSecond = autoScrollsPerSecond
        self.displayLink?.add(to: .main, forMode: .default)
    }

    func stopAutoScroll() {
        displayLink?.invalidate()
        displayLink = nil
        isAutoScrollingUp = false
        isAutoScrollingDown = false
    }

    func update(point: CGPoint) {
        fatalError("Abstract method, override in the subclass")
    }

    @objc
    private func onDisplayLink() {
        if shouldStopAutoScrollUp || shouldStopAutoScrollDown {
            stopAutoScroll()
            return
        }

        guard let currentPoint = currentPoint else { return }
        var point = currentPoint
        point.y += scrollAmount
        var targetOffset = collectionView.contentOffset
        targetOffset.y += scrollAmount
        collectionView.setContentOffset(targetOffset, animated: false)
        update(point: point)
    }
}
