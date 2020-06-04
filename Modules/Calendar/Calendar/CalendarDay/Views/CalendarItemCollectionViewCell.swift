import UIKit
import Assets
import Utils

public final class CalendarItemCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier: String = "CalendarItemCell"
    static let nib: UINib = UINib(nibName: "CalendarItemCollectionViewCell", bundle: Assets.bundle)

    private var calendarItem: CalendarItem!

    // MARK: Outlets
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var bottomDragIndicator: UIView!
    @IBOutlet var topDragIndicator: UIView!
    @IBOutlet var bottomLine: UIView!

    // MARK: Drawing related properties
    private var backgroundLayer = CALayer()
    private var patternLayer = CALayer()
    private var tintLayer = CALayer()
    private var topBorderLayer = CAShapeLayer()
    private var bottomBorderLayer = CAShapeLayer()
    private var topDragIndicatorBorderLayer = CAShapeLayer()
    private var bottomDragIndicatorBorderLayer = CAShapeLayer()
    private var itemTintColor: UIColor = .black

    private let dashLineHeight: CGFloat = 14
    private let halfLineWidth: CGFloat = 0.5

    private var itemColor: UIColor {
        UIColor(hex: calendarItem.color)
    }

    private var foregroundColor: UIColor {
        switch calendarItem.value {
        case .calendarEvent:
            return itemColor
        case .timeEntry(let timeEntry):
            return timeEntry.duration == nil
                ? itemColor
                : itemColor.foregroundColor
        }
    }

    private var tintLayerColor: UIColor {
        isRunningTimeEntry ? itemColor.withAlphaComponent(0.04) : .clear
    }

    private var patternLayerColor: UIColor {
        switch calendarItem.value {
        case .calendarEvent:
            return itemColor.withAlphaComponent(0.24)
        case .timeEntry(let timeEntry):
            if timeEntry.duration != nil {
                return itemColor
            } else {
                let patternTint = itemColor.withAlphaComponent(0.1)
                let patternTemplate = Images.Calendar.stripesPattern
                UIGraphicsBeginImageContextWithOptions(patternTemplate.size, false, patternTemplate.scale)
                let context = UIGraphicsGetCurrentContext()
                context?.scaleBy(x: 1, y: -1)
                context?.translateBy(x: 0, y: -patternTemplate.size.height)
                patternTint.setFill()
                patternTemplate.drawAsPattern(in: CGRect(origin: .zero, size: patternTemplate.size))
                let pattern = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                return UIColor(patternImage: pattern)
            }
        }
    }

    // MARK: Touch related properties
    private var topDragTouchArea: CGRect { topDragIndicator.frame.insetBy(dx: -20, dy: -20) }
    private var bottomDragTouchArea: CGRect { bottomDragIndicator.frame.insetBy(dx: -20, dy: -20) }

    // MARK: Convenience properties
    private var isEditing = false
    private var isRunningTimeEntry: Bool {
        if case let .timeEntry(timeEntry) = calendarItem.value {
            return timeEntry.duration == nil
        }
        return false
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.insertSublayer(topBorderLayer, at: 0)
        contentView.layer.insertSublayer(bottomBorderLayer, at: 1)
        contentView.layer.insertSublayer(backgroundLayer, at: 2)
        contentView.layer.insertSublayer(patternLayer, at: 3)
        contentView.layer.insertSublayer(tintLayer, at: 4)

        contentView.bringSubviewToFront(topDragIndicator)
        contentView.bringSubviewToFront(bottomDragIndicator)

        configureDragIndicator(topDragIndicator, borderLayer: topDragIndicatorBorderLayer)
        configureDragIndicator(bottomDragIndicator, borderLayer: bottomDragIndicatorBorderLayer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateShadow()
        updateBorderLayers()
        updateBackgroundLayers()
    }

    func configure(with calendarItem: CalendarItem) {
        self.calendarItem = calendarItem
        updateView()
    }

    private func updateView() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        descriptionLabel.text = calendarItem.description
        descriptionLabel.textColor = foregroundColor

        backgroundLayer.backgroundColor = Colors.background.cgColor
        patternLayer.backgroundColor = patternLayerColor.cgColor
        tintLayer.backgroundColor = tintLayerColor.cgColor
        backgroundColor = Colors.background
        switch calendarItem.value {
        case .calendarEvent: bottomLine.isHidden = false
        default: bottomLine.isHidden = true
        }
        bottomLine.backgroundColor = itemColor

        updateIcon()
        updateBorderStyle()
        updateDragIndicators()

        CATransaction.commit()
    }

    private func updateShadow() {
        if isEditing {
            let shadowPath = UIBezierPath(rect: bounds).cgPath
            layer.shadowPath = shadowPath
            layer.cornerRadius = 2
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.1
            layer.masksToBounds = false
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowColor = UIColor.black.cgColor
        } else {
            layer.shadowOpacity = 0
        }
    }

    private func updateIcon() {
        switch calendarItem.value {
        case .calendarEvent:
            iconImageView.isHidden = false
            iconImageView.tintColor = foregroundColor
            iconImageView.image = Images.Calendar.calendarSmall
        case .timeEntry:
            iconImageView.isHidden = true
        }
    }

    private func updateBorderStyle() {
        topBorderLayer.fillColor = UIColor.clear.cgColor
        topBorderLayer.strokeColor = isRunningTimeEntry ? itemColor.cgColor : UIColor.clear.cgColor
        topBorderLayer.lineWidth = 1.5
        topBorderLayer.lineCap = .round

        bottomBorderLayer.fillColor = UIColor.clear.cgColor
        bottomBorderLayer.strokeColor = isRunningTimeEntry ? itemColor.cgColor : UIColor.clear.cgColor
        bottomBorderLayer.lineWidth = 1.5
        bottomBorderLayer.lineCap = .round
        bottomBorderLayer.lineDashPattern = [4, 6]
    }

    private func updateBorderLayers() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        topBorderLayer.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height - dashLineHeight)
        bottomBorderLayer.frame = CGRect(x: 0, y: contentView.bounds.height - dashLineHeight, width: contentView.bounds.width, height: dashLineHeight)

        let topBorderBezierPathRect = topBorderLayer.bounds.insetBy(dx: halfLineWidth, dy: halfLineWidth)
        let topBorderBezierPath = UIBezierPath(roundedRect: topBorderBezierPathRect,
                                               byRoundingCorners: [.topLeft, .topRight],
                                               cornerRadii: CGSize(width: 2, height: 2))
        topBorderLayer.path = topBorderBezierPath.cgPath

        let bottomBorderBezierPathRect = bottomBorderLayer.bounds.insetBy(dx: halfLineWidth, dy: halfLineWidth)
        let bottomBorderBezierPath = UIBezierPath(roundedRect: bottomBorderBezierPathRect,
                                                  byRoundingCorners: [.bottomLeft, .bottomRight],
                                                  cornerRadii: CGSize(width: 2, height: 2))
        bottomBorderLayer.path = bottomBorderBezierPath.cgPath

        CATransaction.commit()
    }

    private func updateBackgroundLayers() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)

        let borderWidth: CGFloat = isRunningTimeEntry ? 1.5 : 0
        let rect = contentView.bounds.insetBy(dx: borderWidth, dy: borderWidth)

        backgroundLayer.frame = rect
        patternLayer.frame = rect
        tintLayer.frame = rect

        CATransaction.commit()
    }

    private func updateDragIndicators() {
        topDragIndicator.isHidden = !isEditing
        bottomDragIndicator.isHidden = !isEditing || isRunningTimeEntry
        topDragIndicatorBorderLayer.strokeColor = itemColor.cgColor
        bottomDragIndicatorBorderLayer.strokeColor = itemColor.cgColor
    }

    private func configureDragIndicator(_ dragIndicator: UIView, borderLayer: CAShapeLayer) {
        let rect = dragIndicator.bounds
        borderLayer.path = UIBezierPath.init(ovalIn: rect).cgPath
        borderLayer.borderWidth = 2
        borderLayer.fillColor = UIColor.clear.cgColor
        dragIndicator.layer.addSublayer(borderLayer)
    }
}