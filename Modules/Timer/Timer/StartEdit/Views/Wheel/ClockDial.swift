import UIKit
import Utils

class ClockDial: UIView {

    private let angleOffsetCorrection: CGFloat = .pi

    private var segmentsRadius: CGFloat = 0
    private var numbersRadius: CGFloat = 0
    private let radius: CGFloat
    private let wheelCenter: CGPoint
    private let wheelThickness: CGFloat
    private let thickSegmentColor: CGColor
    private let thinSegmentColor: CGColor
    private var smallRadius: CGFloat = 0

    private var thickSegmentDimensions: CGSize { CGSize(width: 0.01328125 * radius, height: 0.0390625 * radius) }
    private var thinSegmentDimensions: CGSize { CGSize(width: 0.00625 * radius, height: 0.0390625 * radius) }
    private var numberFrameDimensions: CGSize { CGSize(width: 0.1328125 * radius, height: 0.1328125 * radius) }
    private var numberFontSize: CGFloat { 0.103125 * radius }
    private var smallRadiusDifference: CGFloat { 0.0390625 * radius }
    private var numbersRadiusDifference: CGFloat { 0.15625 * radius }

    init(frame: CGRect,
         wheelCenter: CGPoint,
         radius: CGFloat,
         smallRadius: CGFloat,
         wheelThickness: CGFloat,
         thickSegmentColor: CGColor,
         thinSegmentColor: CGColor) {

        self.wheelCenter = wheelCenter
        self.radius = radius
        self.smallRadius = smallRadius
        self.wheelThickness = wheelThickness
        self.thickSegmentColor = thickSegmentColor
        self.thinSegmentColor = thinSegmentColor
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        subviews.forEach { $0.removeFromSuperview() }

        segmentsRadius = smallRadius - smallRadiusDifference
        numbersRadius = smallRadius - numbersRadiusDifference

        addClockDial()
    }

    private func addClockDial() {
        let dial = CALayer()
        let minuteSegmentsPerHourMark = .minutesInAnHour / .hoursOnTheClock

        let scaledThickSegment = convertToCenteredRect(thickSegmentDimensions)
        let scaledThinSegment = convertToCenteredRect(thinSegmentDimensions)

        for index in 1...Int.minutesInAnHour {
            let angle = -(.fullCircle * CGFloat(index) / CGFloat(Int.minutesInAnHour) + angleOffsetCorrection)
            let correspondsToHourMark = index % Int(minuteSegmentsPerHourMark) == 0
            let (rect, color) = correspondsToHourMark
                ? (scaledThickSegment, thickSegmentColor)
                : (scaledThinSegment, thinSegmentColor)
            let minuteLayer = createMinuteSegment(rect: rect,
                                                  color: color,
                                                  distanceFromCenter: segmentsRadius,
                                                  angle: angle,
                                                  wheelCenter: wheelCenter)
            dial.addSublayer(minuteLayer)

            if correspondsToHourMark {
                let numberView = createMinuteNumber(number: index,
                                                    color: color,
                                                    distanceFromCenter: numbersRadius,
                                                    angle: angle,
                                                    wheelCenter: wheelCenter)
                addSubview(numberView)
            }
        }

        layer.addSublayer(dial)
    }

    private func convertToCenteredRect(_ size: CGSize) -> CGRect {
        CGRect(x: -size.width / 2,
               y: -size.height / 2,
               width: size.width,
               height: size.height)
    }

    private func createMinuteSegment(rect: CGRect, color: CGColor, distanceFromCenter: CGFloat, angle: CGFloat, wheelCenter: CGPoint) -> CALayer {
        let minuteLayer = CAShapeLayer()
        var transform = translationTransform(distance: distanceFromCenter, angle: angle, wheelCenter: wheelCenter)
            .rotated(by: -angle)
        let path = CGPath(rect: rect, transform: &transform)
        minuteLayer.path = path
        minuteLayer.fillColor = color
        return minuteLayer
    }

    private func translationTransform(distance: CGFloat, angle: CGFloat, wheelCenter: CGPoint) -> CGAffineTransform {
        let transformX = distance * sin(angle)
        let transformY = distance * cos(angle)

        return CGAffineTransform(translationX: wheelCenter.x + transformX, y: wheelCenter.y + transformY)
    }

    // swiftlint:disable no_color_initializers
    private func createMinuteNumber(number: Int, color: CGColor, distanceFromCenter: CGFloat, angle: CGFloat, wheelCenter: CGPoint) -> UIView {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: numberFontSize, weight: .regular)
        label.text = "\(number)"
        label.textColor = UIColor(cgColor: color)
        label.frame = convertToCenteredRect(numberFrameDimensions)
        label.textAlignment = .center

        let translation = translationTransform(distance: distanceFromCenter, angle: angle, wheelCenter: wheelCenter)
        label.transform = translation

        return label
    }
    // swiftlint:enable no_color_initializers
}
