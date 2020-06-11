import CoreGraphics
import Foundation
import UIKit
import Assets
import Utils

public class Cap: CAShapeLayer {
    // The sizes are relative to the radius of the wheel.
    // The radius of the wheel in the design document is 128 points.
    private let outerRadius: CGFloat = 16.5 / 128.0
    private let innerRadius: CGFloat = 14.05 / 128.0

    private let circleLayer: CAShapeLayer
    private let imageLayer: CALayer
    private let shadowDirection: ShadowDirection

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private init(icon: CGImage, scale: (CGFloat) -> (CGFloat), iconHeight: CGFloat, iconWidth: CGFloat, shadowDirection: ShadowDirection) {
        self.shadowDirection = shadowDirection
        let center = CGPoint(x: 0, y: 0)

        let outerPath = UIBezierPath()
        outerPath.addArc(withCenter: center,
                         radius: scale(outerRadius),
                         startAngle: 0,
                         endAngle: .fullCircle,
                         clockwise: false)

        let innerPath = UIBezierPath()
        innerPath.addArc(withCenter: center,
                         radius: scale(innerRadius),
                         startAngle: 0,
                         endAngle: .fullCircle,
                         clockwise: false)

        circleLayer = CAShapeLayer()
        circleLayer.path = innerPath.cgPath

        let imageFrame = CGRect(x: center.x - scale(iconWidth) / 2.0,
                                y: center.y - scale(iconHeight) / 2.0,
                                width: scale(iconWidth),
                                height: scale(iconHeight))

        let maskLayer = CALayer()
        maskLayer.contents = icon
        maskLayer.frame = CGRect(x: 0,
                                 y: 0,
                                 width: scale(iconWidth),
                                 height: scale(iconHeight))

        imageLayer = CALayer()
        imageLayer.mask = maskLayer
        imageLayer.frame = imageFrame

        circleLayer.addSublayer(imageLayer)

        super.init()

        path = outerPath.cgPath
        addSublayer(circleLayer)

        shadowRadius = 0.0
        shadowPath = path
        shadowOpacity = 1.0

        traitCollectionDidChange()
    }

    public func traitCollectionDidChange() {
        circleLayer.fillColor = Color.backgroundPrimary.cgColor
        shadowColor = Color.separator.cgColor
    }

    public func set(color: CGColor) {
        fillColor = color
        imageLayer.backgroundColor = color
    }

    // swiftlint:disable identifier_name
    public func set(angle: CGFloat) {
        let direction = angle + CGFloat(shadowDirection.rawValue) * (.pi / 2.0)
        let dx = 1.5 * cos(direction)
        let dy = 1.5 * sin(direction)
        shadowOffset = CGSize(width: dx, height: dy)
    }
    // swiftlint:enable identifier_name

    public static func endCap(scale: (CGFloat) -> (CGFloat)) -> Cap {
        let icon = Images.endLabel
        let iconHeight: CGFloat = 10 / 128
        let iconWidth: CGFloat = 10 / 128

        return Cap(icon: icon.cgImage!, scale: scale, iconHeight: iconHeight, iconWidth: iconWidth, shadowDirection: .left)
    }

    public static func startCap(scale: (CGFloat) -> (CGFloat)) -> Cap {
        let icon = Images.startLabel
        let iconCenterHorizontalCorrection: CGFloat = 1.4 / 128.0
        let iconWidth: CGFloat = 9.0 / 128.0
        let iconHeight: CGFloat = 10.0 / 128.0

        let cap = Cap(icon: icon.cgImage!, scale: scale, iconHeight: iconHeight, iconWidth: iconWidth, shadowDirection: .right)
        cap.frame = CGRect(
            x: cap.frame.minX + scale(iconCenterHorizontalCorrection),
            y: cap.frame.minY,
            width: cap.frame.width,
            height: cap.frame.height
        )

        return cap
    }

    public func setShowOnlyBackground(hidden: Bool) {
        sublayers?.first?.isHidden = hidden
    }

    private enum ShadowDirection: Int {
        case left = 1
        case right = -1
    }
}
