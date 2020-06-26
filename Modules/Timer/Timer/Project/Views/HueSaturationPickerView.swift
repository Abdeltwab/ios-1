import UIKit
import Utils

class HueSaturationPickerView: UIControl {
    // swiftlint:disable no_ui_colors
    private let circleDiameter: CGFloat = 30
    private var circleRadius: CGFloat { circleDiameter / 2 }

    private let outerCircleDiameter: CGFloat = 32
    private var outerCircleRadius: CGFloat { outerCircleDiameter / 2 }
    private let outerCircleColor = UIColor.white

    private static let defautlColor = UIColor(hex: "3178be")
    public var hue: CGFloat = defautlColor.hsb.hue
    public var saturation: CGFloat = defautlColor.hsb.saturation

    private var _value: CGFloat = 0
    public var value: Double {
        get {
            return Double(_value)
        }
        set {
            _value = complement(CGFloat(newValue))
            setNeedsDisplay()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        updateLocation(point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        updateLocation(point)
    }

    private func updateLocation(_ touchPoint: CGPoint) {
        let pointX = touchPoint.x.clamp(min: CGFloat(0.0), max: frame.width)
        let pointY = touchPoint.y.clamp(min: CGFloat(0.0), max: frame.height)

        hue = pointX / frame.width
        saturation = complement(pointY / frame.height)

        setNeedsDisplay()
        sendActions(for: .valueChanged)
    }

    private func complement(_ number: CGFloat) -> CGFloat {
        abs(number - 1)
    }

    // swiftlint:disable identifier_name force_cast line_length
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawRainbowBackground(rect: bounds)

        drawDarkOverlay(rect: bounds)

        let x = frame.width * hue - circleRadius
        let y = frame.height * complement(saturation) - circleRadius

        let outerCircleRect = CGRect(x: x - 1, y: y - 1, width: outerCircleDiameter, height: outerCircleDiameter)
        drawOuterCircleWithShadow(rect: outerCircleRect)

        let circleRect = CGRect(x: x, y: y, width: circleDiameter, height: circleDiameter)
        drawColorCircle(rect: circleRect)
    }

    private func drawRainbowBackground(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        let red = UIColor.red
        let yellow = UIColor.yellow
        let green = UIColor.green
        let cyan = UIColor.cyan
        let blue = UIColor.blue
        let magenta = UIColor.magenta
        let borderColor = UIColor(hex: "CECECE")

        let step: CGFloat = 1/6
        let locations: [CGFloat] = [0.0, step * 1, step * 2, step * 3, step * 4, step * 5, 1.0]
        let gradient = CGGradient(colorsSpace: nil, colors: [red.cgColor, yellow.cgColor, green.cgColor, cyan.cgColor, blue.cgColor, magenta.cgColor, red.cgColor] as CFArray, locations: locations)!

        let rainbowRect = CGRect(x: rect.minX + 0.5, y: rect.minY + 0.5, width: rect.width - 1, height: rect.height - 1)
        let rainbowPath = UIBezierPath(roundedRect: rainbowRect, cornerRadius: 8)
        context.saveGState()
        rainbowPath.addClip()
        context.drawLinearGradient(gradient,
            start: CGPoint(x: rainbowRect.minX, y: rainbowRect.midY),
            end: CGPoint(x: rainbowRect.maxX, y: rainbowRect.midY),
            options: [])
        context.restoreGState()
        borderColor.setStroke()
        rainbowPath.lineWidth = 1
        rainbowPath.lineCapStyle = .round
        rainbowPath.lineJoinStyle = .round
        rainbowPath.stroke()

        let whiteGradientOverlay = CGGradient(colorsSpace: nil, colors: [UIColor.clear.cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 1])!
        let gradientOverlayRect = CGRect(x: rect.minX + 1, y: rect.minY + 1, width: rect.width - 2, height: rect.height - 2)
        let gradientOverlayPath = UIBezierPath(roundedRect: gradientOverlayRect, cornerRadius: 7.5)
        context.saveGState()
        gradientOverlayPath.addClip()
        context.drawLinearGradient(whiteGradientOverlay,
            start: CGPoint(x: gradientOverlayRect.midX, y: gradientOverlayRect.minY),
            end: CGPoint(x: gradientOverlayRect.midX, y: gradientOverlayRect.maxY),
            options: [])

        context.restoreGState()
    }

    private func drawOuterCircleWithShadow(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!

        let shadow = NSShadow()
        shadow.shadowColor = UIColor.black.withAlphaComponent(0.3)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 3

        let ovalPath = UIBezierPath(ovalIn: rect)
        context.saveGState()
        context.setShadow(offset: shadow.shadowOffset, blur: shadow.shadowBlurRadius, color: (shadow.shadowColor as! UIColor).cgColor)
        outerCircleColor.setFill()
        ovalPath.fill()
        context.restoreGState()
    }

    private func drawColorCircle(rect: CGRect) {
        let ovalPath = UIBezierPath(ovalIn: rect)
        UIColor(hue: hue, saturation: saturation, brightness: complement(_value), alpha: 1).setFill()
        ovalPath.fill()
    }

    private func drawDarkOverlay(rect: CGRect) {
        let color = UIColor.black.withAlphaComponent(_value)

        let opacityOverlayPath = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        color.setFill()
        opacityOverlayPath.fill()
    }
    // swiftlint:enable identifier_name force_cast line_length no_ui_colors
}
