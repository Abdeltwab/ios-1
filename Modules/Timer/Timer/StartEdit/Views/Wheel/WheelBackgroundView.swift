import UIKit
import Utils
import CoreGraphics

class WheelBackgroundView: UIView {
    private let wheelBackgroundColor: CGColor = UIColor.gray.withAlphaComponent(0.1).cgColor
    private let thickSegmentColor: CGColor = UIColor.gray.withAlphaComponent(0.6).cgColor
    private let thinSegmentColor: CGColor = UIColor.gray.withAlphaComponent(0.3).cgColor
    private var smallRadius: CGFloat = 0

    private var radius: CGFloat { 0.5 * min(frame.width, frame.height) }
    private var wheelThickness: CGFloat { 0.2578125 * radius }
    private var wheelCenter: CGPoint {
        frame.width > frame.height
        ? CGPoint(x: radius + (frame.width - frame.height) / 2, y: radius)
        : CGPoint(x: radius, y: radius + (frame.height - frame.width) / 2) }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        smallRadius = radius - wheelThickness

        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        subviews.forEach { $0.removeFromSuperview() }

        addLayersAndViews()
    }

    private func addLayersAndViews() {
        let wheel = WheelShape(center: wheelCenter,
                          outerRadius: radius,
                          innerRadius: smallRadius,
                          color: wheelBackgroundColor)
        layer.addSublayer(wheel)

        let dial = ClockDial(frame: bounds,
                             wheelCenter: wheelCenter,
                             radius: radius,
                             smallRadius: smallRadius,
                             wheelThickness: wheelThickness,
                             thickSegmentColor: thickSegmentColor,
                             thinSegmentColor: thickSegmentColor)
        addSubview(dial)
    }
}
