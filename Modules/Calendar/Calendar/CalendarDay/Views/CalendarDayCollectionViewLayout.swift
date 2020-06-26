import UIKit
import OtherServices
import Utils

protocol CalendarDayCollectionViewLayoutDelegate: class {
    func calendarItem(at indexPath: IndexPath) -> CalendarItem?
}

class CalendarDayCollectionViewLayout: UICollectionViewLayout {

    unowned var delegate: CalendarDayCollectionViewLayoutDelegate!

    struct SupplementaryViews {
        public static let hourIndicatorKind = "Hour"
        public static let editingHourIndicatorKind = "EditingHour"
        public static let currentTimeKind = "CurrentTime"
    }

    // MARK: Math properties

    private let maxWidth: CGFloat = 834
    private let hoursPerDay: Int = 24
    private let minHourHeight: CGFloat = 28
    private let maxHourHeight: CGFloat = 28 * 4
    private(set) var hourHeight: CGFloat = 56

    private let leftPadding: CGFloat = 76
    private let hourSupplementaryLabelHeight: CGFloat = 20
    private let currentTimeSupplementaryLeftOffset: CGFloat = -18
    private var contentViewHeight: CGFloat { CGFloat(hoursPerDay) * hourHeight }
    private let verticalItemSpacing: CGFloat = 1
    private var minItemHeight: CGFloat { hourHeight / 4 }

    private var sideMargin: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.width >= maxWidth ? (collectionView.frame.width - maxWidth) / 2 : 0
    }

    private var rightPadding: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        switch collectionView.traitCollection.horizontalSizeClass {
        case .compact: return 16
        case .regular: return 20
        default: return 0
        }
    }

    private var horizontalItemSpacing: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        switch collectionView.traitCollection.horizontalSizeClass {
        case .compact: return 4
        case .regular: return 11
        default: return 0
        }
    }

    // MARK: Index paths
    private var itemsIndexPaths: [IndexPath] {
        guard let sections = collectionView?.numberOfSections, sections > 0 else { return [] }
        guard let itemsInSection = collectionView?.numberOfItems(inSection: 0) else { return [] }
        return (0..<itemsInSection).map({ IndexPath(item: $0, section: 0) })
    }

    private var hourIndicatorsIndexPaths: [IndexPath] {
        guard let sections = collectionView?.numberOfSections, sections > 0 else { return [] }
        return (0...24).map({ IndexPath(item: $0, section: 0) })
    }

    private var editingHourIndicatorsIndexPaths: [IndexPath] {
        guard let sections = collectionView?.numberOfSections, sections > 0 else { return [] }
        return (0...1).map({ IndexPath(item: $0, section: 0) })
    }

    private var currentTimeIndicatorIndexPath: IndexPath? {
        guard let sections = collectionView?.numberOfSections, sections > 0 else { return nil }
        return IndexPath(item: 0, section: 0)
    }

    // MARK: Cached attributes
    private var itemLayoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var hourIndicatorLayoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var editingHourIndicatorLayoutAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var currentTimeLayoutAttributes: UICollectionViewLayoutAttributes?

    private let time: Time
    private var currentTimeInvalidationTimer: Timer!

    init(time: Time) {
        self.time = time
        super.init()
        self.currentTimeInvalidationTimer = Timer.scheduledTimer(timeInterval: TimeInterval(minutes: 1),
                                                                 target: self,
                                                                 selector: #selector(invalidateCurrentTimeIndicator),
                                                                 userInfo: nil,
                                                                 repeats: true)
        self.currentTimeInvalidationTimer.fire()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UICollectionViewLayout requirements
    override func invalidateLayout() {
        itemLayoutAttributes = [:]
        hourIndicatorLayoutAttributes = [:]
        editingHourIndicatorLayoutAttributes = [:]
        currentTimeLayoutAttributes = nil
        super.invalidateLayout()
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return true }
        return collectionView.bounds.width != newBounds.width
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let width = collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
        let height = contentViewHeight + hourSupplementaryLabelHeight
        return CGSize(width: width, height: height)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemsAttributes = itemsIndexPaths.compactMap(layoutAttributesForItem(at:))

        let hourIndicatorsAttributes = hourIndicatorsIndexPaths
            .compactMap({ layoutAttributesForSupplementaryView(ofKind: SupplementaryViews.hourIndicatorKind, at: $0) })

        let editingHourIndicatorsAttributes = editingHourIndicatorsIndexPaths
            .compactMap({ layoutAttributesForSupplementaryView(ofKind: SupplementaryViews.editingHourIndicatorKind, at: $0) })

        let currentTimeIndicatorAttributes = [currentTimeIndicatorIndexPath
            .flatMap({ layoutAttributesForSupplementaryView(ofKind: SupplementaryViews.currentTimeKind, at: $0) })]
            .compactMap({ $0 })

        return itemsAttributes + hourIndicatorsAttributes + editingHourIndicatorsAttributes + currentTimeIndicatorAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let cachedAttributes = itemLayoutAttributes[indexPath] {
            return cachedAttributes
        }

        guard let calendarItem = delegate.calendarItem(at: indexPath) else { return nil }
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = frame(for: calendarItem)
        attributes.zIndex = zIndex(for: calendarItem)
        itemLayoutAttributes[indexPath] = attributes
        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case SupplementaryViews.hourIndicatorKind:
            if let cachedAttributes = hourIndicatorLayoutAttributes[indexPath] {
                return cachedAttributes
            }

            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViews.hourIndicatorKind,
                                                              with: indexPath)
            attributes.frame = frame(for: indexPath.item)
            hourIndicatorLayoutAttributes[indexPath] = attributes
            return attributes

        case SupplementaryViews.editingHourIndicatorKind:
            if let cachedAttributes = editingHourIndicatorLayoutAttributes[indexPath] {
                return cachedAttributes
            }

            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViews.editingHourIndicatorKind,
                                                              with: indexPath)
            attributes.frame = frame(for: indexPath.item)
            editingHourIndicatorLayoutAttributes[indexPath] = attributes
            return attributes

        case SupplementaryViews.currentTimeKind:
            if let cachedAttributes = currentTimeLayoutAttributes {
                return cachedAttributes
            }

            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: SupplementaryViews.currentTimeKind,
                                                              with: indexPath)
            attributes.frame = frameForCurrentTime()
            attributes.zIndex = 500
            currentTimeLayoutAttributes = attributes
            return attributes

        default:
            fatalError("Unknown element kind: \(elementKind)")
        }
    }

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        updateItems.map({ $0.indexPathBeforeUpdate }).forEach { indexPathToInvalidate in
            guard let indexPathToInvalidate = indexPathToInvalidate else { return }
            itemLayoutAttributes.removeValue(forKey: indexPathToInvalidate)
        }
    }

    // swiftlint:disable line_length
    // swiftlint:disable identifier_name
    private func frame(for calendarItem: CalendarItem) -> CGRect {
        let startDateComponents = Calendar.current.dateComponents([.hour, .minute], from: calendarItem.start)
        let yHour = hourHeight * CGFloat(startDateComponents.hour ?? 0)
        let yMins = hourHeight * CGFloat(startDateComponents.minute ?? 0) / CGFloat(Int.minutesInAnHour)

        let interItemSpacing = CGFloat(calendarItem.totalColumns - 1) * horizontalItemSpacing
        let width = (collectionViewContentSize.width - leftPadding - rightPadding - interItemSpacing - (sideMargin * 2)) / CGFloat(calendarItem.totalColumns)
        let height = max(minItemHeight, hourHeight * CGFloat(calendarItem.duration / TimeInterval(Int.secondsInAnHour)) - verticalItemSpacing)
        let x = sideMargin + leftPadding + (width + horizontalItemSpacing) * CGFloat(calendarItem.columnIndex)
        let y = yHour + yMins + verticalItemSpacing

        return CGRect(x: x, y: y, width: width, height: height)
    }
    // swiftlint:enable line_length
    // swiftlint:enable identifier_name

    private func zIndex(for calendarItem: CalendarItem) -> Int {
        return 100 // Return a higher zIndex when the item is selected
    }

    // swiftlint:disable identifier_name
    private func frame(for hourIndicator: Int) -> CGRect {
        let width = collectionViewContentSize.width - rightPadding - (sideMargin * 2)
        let height = hourSupplementaryLabelHeight
        let x = sideMargin
        let y = hourHeight * CGFloat(hourIndicator) - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    // swiftlint:enable identifier_name

    // swiftlint:disable identifier_name
    private func frameForCurrentTime() -> CGRect {
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time.now())
        let yHour = hourHeight * CGFloat(dateComponents.hour ?? 0)
        let yMins = hourHeight * CGFloat(dateComponents.minute ?? 0) / CGFloat(Int.minutesInAnHour)

        let width = collectionViewContentSize.width - leftPadding - rightPadding - currentTimeSupplementaryLeftOffset - (sideMargin * 2)
        let height: CGFloat = 8
        let x = sideMargin + leftPadding + currentTimeSupplementaryLeftOffset
        let y = yHour + yMins - height / 2
        return CGRect(x: x, y: y, width: width, height: height)
    }
    // swiftlint:enable identifier_name

    @objc
    private func invalidateCurrentTimeIndicator() {
        if let currentTimeIndicatorIndexPath = currentTimeIndicatorIndexPath {
            let invalidationContext = UICollectionViewLayoutInvalidationContext()
            currentTimeLayoutAttributes = nil
            invalidationContext.invalidateSupplementaryElements(ofKind: SupplementaryViews.currentTimeKind, at: [currentTimeIndicatorIndexPath])
            invalidateLayout(with: invalidationContext)
        }
    }

    // MARK: TimeInterval at point
    public func timeInterval(at point: CGPoint) -> TimeInterval {
        return TimeInterval(point.y / hourHeight) * TimeInterval.secondsInAnHour
    }

    public func setScale(_ scale: CGFloat, center: CGPoint) {
        guard let collectionView = collectionView else { return }
        let newHourHeight = hourHeight * scale

        if minHourHeight...maxHourHeight ~= newHourHeight {
            let offset = center.y - center.y * scale
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y - offset)
        }

        hourHeight = newHourHeight.clamp(minHourHeight...maxHourHeight)

        invalidateLayout()
    }
}
