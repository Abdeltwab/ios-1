import UIKit
import Utils

class HueSaturationPickerView: UIControl {
    private let opacityLayer = CALayer()

    // swiftlint:disable no_ui_colors
    private let colorLayer: CAGradientLayer = {
        var gLayer = CAGradientLayer()
        let step: Double = 1/6
        gLayer.cornerRadius = 8
        gLayer.startPoint = CGPoint(x: 0, y: 0)
        gLayer.endPoint = CGPoint(x: 1, y: 0)
        gLayer.locations = [0.0, step * 1, step * 2, step * 3, step * 4, step * 5, 1.0] as [NSNumber]
        gLayer.colors = [
            UIColor.red.cgColor,
            UIColor.yellow.cgColor,
            UIColor.green.cgColor,
            UIColor.cyan.cgColor,
            UIColor.blue.cgColor,
            UIColor.magenta.cgColor,
            UIColor.red.cgColor
        ]

        let mask = CAGradientLayer()
        mask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        mask.locations = [0.0, 1.0] as [NSNumber]

        gLayer.mask = mask

        return gLayer
    }()

    private let circleDiameter: CGFloat = 30
    private var circleRadius: CGFloat { circleDiameter / 2 }
    private let circleColor: CGColor = UIColor.white.cgColor

    private let outerCircleDiameter: CGFloat = 32
    private var outerCircleRadius: CGFloat { outerCircleDiameter / 2 }
    private let outerCircleColor: CGColor = UIColor.black.withAlphaComponent(0.3).cgColor

    private static let defautlColor = UIColor(hex: "3178be")
    public var color: UIColor = defautlColor
    public var hue: CGFloat = defautlColor.hsb.hue
    public var saturation: CGFloat = defautlColor.hsb.saturation

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        opacityLayer.cornerRadius = 8
        //        opacityLayer.backgroundColor = UIColor.black.withAlphaComponent(complement(value)).CGColor
        layer.insertSublayer(opacityLayer, at: 0)
        layer.insertSublayer(colorLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        opacityLayer.frame = bounds
        colorLayer.frame = bounds
        colorLayer.mask?.frame = bounds
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
    }

    // swiftlint:disable identifier_name
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        let x = frame.width * hue - circleRadius
        let y = frame.height * complement(saturation) - circleRadius

        let circleRect = CGRect(x: x, y: y, width: circleDiameter, height: circleDiameter)
        let path = UIBezierPath.init(roundedRect: circleRect, cornerRadius: circleRadius)
        path.lineWidth = 2
        context.addPath(path.cgPath)
        context.setStrokeColor(circleColor)
        context.setFillColor(UIColor.init(hue: hue, saturation: saturation, brightness: 1, alpha: 1).cgColor)
        context.drawPath(using: .fillStroke)

        let outerCircleRect = CGRect(x: x - 1, y: y - 1, width: outerCircleDiameter, height: outerCircleDiameter)
        let outerPath = UIBezierPath.init(roundedRect: outerCircleRect, cornerRadius: outerCircleRadius)
        outerPath.lineWidth = 1
        context.addPath(outerPath.cgPath)
        context.setStrokeColor(outerCircleColor)
        context.drawPath(using: .stroke)
    }
    // swiftlint:enable identifier_name

    private func complement(_ number: CGFloat) -> CGFloat {
        abs(number - 1)
    }

    // swiftlint:enable no_ui_colors
}
