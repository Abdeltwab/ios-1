import Foundation
import UIKit
import CoreGraphics
import RxSwift
import Utils

// swiftlint:disable type_body_length
public class WheelForegroundView: UIControl {
    public var minimumStartTime: Date = .distantPast
    public var maximumStartTime: Date = Date()
    public var minimumEndTime: Date = Date()
    public var maximumEndTime: Date = .distantFuture
    
    private var _startTime: Date = Date().addingTimeInterval(-30*60)
    public var startTime: Date {
        get { return _startTime }
        set(value) {
            guard _startTime != value else { return }
            _startTime = value.clamp(between: minimumStartTime, and: maximumStartTime)
            setNeedsLayout()
        }
    }

    private var _endTime: Date = Date()
    public var endTime: Date {
        get { return _endTime < _startTime ? _startTime : _endTime }
        set(value) {
            guard _endTime != value else { return }
            _endTime = value.clamp(between: minimumEndTime, and: maximumEndTime)
            setNeedsLayout()
        }
    }

    public var duration: TimeInterval {
        get { return endTime.timeIntervalSince(startTime) }
        set { endTime = startTime.addingTimeInterval(newValue) }
    }
    
    private var _isRunning: Bool = false
    public var isRunning: Bool {
        get { return _isRunning }
        set(value) {
            guard isRunning != value else { return }
            _isRunning = value
            setNeedsLayout()
        }
    }

    private var radius: CGFloat { layer.bounds.width / 2 }
    private var smallRadius: CGFloat { radius - resize(originalSize: wheelThickness) }
    private var wheelThickness: CGFloat = 33 / 128
    private var thickness: CGFloat { radius - smallRadius }

    private var wheelBackgroundColor: UIColor {
        return UIColor.rainbowColors.getPingPongIndexedItem(numberOfFullLoops)
    }

    private var foregroundColor: UIColor {
        return UIColor.rainbowColors.getPingPongIndexedItem(numberOfFullLoops + 1)
    }
    
    private var startTimePosition: CGPoint = .zero
    private var endTimePosition: CGPoint = .zero

    private var startTimeAngle: CGFloat { startTime.angleOnTheDial.positiveAngle }
    private var endTimeAngle: CGFloat { endTime.angleOnTheDial.positiveAngle }
    
    private let extendedRadiusMultiplier: CGFloat = 1.5
    private var endPointsRadius: CGFloat { (radius + smallRadius) / 2 }

    private var isDragging: Bool = false
    private var feedbackGenerator: UISelectionFeedbackGenerator?
    private var updateType: WheelUpdateType = .editStartTime
    private var editBothAtOnceStartTimeAngleOffset: CGFloat = 0

    private var numberOfFullLoops: Int { Int(ceiling: endTime.timeIntervalSince(startTime)) / .secondsInAnHour }
    private var isFullCircle: Bool { numberOfFullLoops > 0 }
    
    private var fullWheel: CAShapeLayer?
    private var arc: Arc!
    private var endCap: Cap!
    private var startCap: Cap!
    private var currentFrame: CGRect!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTouch))
        addGestureRecognizer(gestureRecognizer)
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        calculateEndPointPositions()

        if currentFrame != frame || arc == nil {
            createSubLayers()
            currentFrame = frame
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        updateUIElements()

        CATransaction.commit()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        startCap.traitCollectionDidChange()
        endCap.traitCollectionDidChange()

        CATransaction.commit()
    }

    private func updateUIElements() {
        startCap.position = startTimePosition
        startCap.set(color: foregroundColor.cgColor)
        startCap.set(angle: startTimeAngle)
        endCap.position = endTimePosition
        endCap.set(color: foregroundColor.cgColor)
        endCap.set(angle: endTimeAngle)
        endCap.setShowOnlyBackground(hidden: isRunning)

        fullWheel?.fillColor = wheelBackgroundColor.cgColor
        fullWheel?.isHidden = !isFullCircle

        arc.set(color: foregroundColor.cgColor)
        arc.update(startAngle: startTimeAngle, endAngle: endTimeAngle)
    }

    private func createSubLayers() {
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })

        let fullWheel = WheelShape(center: layer.bounds.center, outerRadius: radius, innerRadius: smallRadius, color: backgroundColor!.cgColor)
        layer.addSublayer(fullWheel)
        self.fullWheel = fullWheel

        arc = Arc(bounds: layer.bounds, center: layer.bounds.center, radius: (radius + smallRadius) / 2, width: thickness)
        layer.addSublayer(arc)

        endCap = Cap.endCap(scale: resize)
        layer.addSublayer(endCap)

        startCap = Cap.startCap(scale: resize)
        layer.addSublayer(startCap)
    }

    private func calculateEndPointPositions() {
        startTimePosition = .pointOnCircumference(center: layer.bounds.center, angle: startTimeAngle, radius: endPointsRadius)
        endTimePosition = .pointOnCircumference(center: layer.bounds.center, angle: endTimeAngle, radius: endPointsRadius)
    }

    @objc
    private func handleTouch(_ recognizer: UIPanGestureRecognizer) {
        let position = recognizer.location(in: self)
        switch recognizer.state {
        case .began:
            touchesBegan(at: position)
        case .changed:
            touchesMoved(at: position)
        case .ended:
            touchesEnded()
        case .cancelled, .failed:
            touchesCancelled()
        default: break
        }
    }

    private func touchesBegan(at position: CGPoint) {
        guard isValid(position) else { return }
        isDragging = true
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
    }

    private func touchesMoved(at position: CGPoint) {
        guard isDragging else { return }

        let previousAngle: CGFloat
        switch updateType {
        case .editStartTime:
            previousAngle = startTimeAngle
        case .editEndTime:
            previousAngle = endTimeAngle
        case .editBothAtOnce:
            previousAngle = startTimeAngle + editBothAtOnceStartTimeAngleOffset
        }

        let currentAngle = position.angle(to: layer.bounds.center)

        var angleChange = currentAngle - previousAngle
        while angleChange < -.pi {
            angleChange += .fullCircle
        }
        while angleChange > .pi {
            angleChange -= .fullCircle
        }

        let timeChange = angleChange.angleToTime()

        updateEditedTime(diff: timeChange)
    }

    private func touchesCancelled() {
        finishTouchEditing()
    }

    private func touchesEnded() {
        finishTouchEditing()
    }

    private func isValid(_ position: CGPoint) -> Bool {
        if let intention = determineTapIntention(for: position) {
            updateType = intention
            if intention == .editBothAtOnce {
                editBothAtOnceStartTimeAngleOffset = position.angle(to: layer.bounds.center) - startTimeAngle
            }
            return true
        }
        return false
    }

    private func determineTapIntention(for position: CGPoint) -> WheelUpdateType? {
        if touchesStartCap(at: position) {
            return .editStartTime
        }

        if !isRunning && touchesEndCap(position: position) {
            return .editEndTime
        }

        if touchesStartCap(at: position, extendedRadius: true) {
            return .editStartTime
        }

        if !isRunning && touchesEndCap(position: position, extendedRadius: true) {
            return .editEndTime
        }

        if !isRunning && isOnTheWheelBetweenStartAndStop(position) {
            return .editBothAtOnce
        }

        return nil
    }

    private func touchesStartCap(at position: CGPoint, extendedRadius: Bool = false) -> Bool {
        return isCloseEnough(position, startTimePosition, calculateCapRadius(extendedRadius))
    }

    private func touchesEndCap(position: CGPoint, extendedRadius: Bool = false) -> Bool {
        return isCloseEnough(position, endTimePosition, calculateCapRadius(extendedRadius))
    }
        
    private func calculateCapRadius(_ extendedRadius: Bool) -> CGFloat {
        return (extendedRadius ? extendedRadiusMultiplier : 1) * (thickness / 2)
    }
        
    private func isCloseEnough(_ tapPosition: CGPoint, _ endPoint: CGPoint, _ radius: CGFloat) -> Bool {
        tapPosition.distanceSq(to: endPoint) <= radius * radius
    }
        
    private func isOnTheWheelBetweenStartAndStop(_ point: CGPoint) -> Bool {
        let distanceFromCenterSq = layer.bounds.center.distanceSq(to: point)

        if distanceFromCenterSq < smallRadius * smallRadius || distanceFromCenterSq > radius * radius {
            return false
        }

        let angle = point.angle(to: layer.bounds.center)
        return isFullCircle || angle.isBetween(startAngle: startTimeAngle, endAngle: endTimeAngle)
    }

    private func updateEditedTime(diff: TimeInterval) {
        var giveFeedback = false

        switch updateType {
        case .editStartTime:
            let nextStartTime = (startTime + diff).roundedToClosestMinute
            giveFeedback = nextStartTime != startTime
            updateStartTime(time: nextStartTime)

        case .editEndTime:
            let nextEndTime = (endTime + diff).roundedToClosestMinute
            giveFeedback = nextEndTime != endTime
            updateEndTime(time: nextEndTime)

        case .editBothAtOnce:
            let nextStartTime = (startTime + diff).roundedToClosestMinute
            giveFeedback = nextStartTime != startTime
            updateStartAndEndTimes(time: nextStartTime)
        }

        if giveFeedback {
            feedbackGenerator?.selectionChanged()
        }
    }

    private func updateStartTime(time newStartTime: Date) {
        startTime = newStartTime
        sendActions(for: .valueChanged)
    }

    private func updateEndTime(time newEndTime: Date) {
        endTime = newEndTime
        sendActions(for: .valueChanged)
    }

    private func updateStartAndEndTimes(time newStartTime: Date) {
        let duration = endTime.timeIntervalSince(startTime)
        startTime = newStartTime
        endTime = newStartTime + duration
        sendActions(for: .valueChanged)
    }

    private func finishTouchEditing() {
        isDragging = false
        feedbackGenerator = nil
    }

    private func resize(originalSize: CGFloat) -> CGFloat {
        return originalSize * radius
    }

    private enum WheelUpdateType {
        case editStartTime
        case editEndTime
        case editBothAtOnce
    }
}
// swiftlint:enable type_body_length
