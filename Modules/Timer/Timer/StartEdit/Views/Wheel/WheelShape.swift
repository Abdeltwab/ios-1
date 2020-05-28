import UIKit
import Utils

class WheelShape: CAShapeLayer {

    init(center: CGPoint, outerRadius: CGFloat, innerRadius: CGFloat, color: CGColor) {
        super.init()

        let discPath = UIBezierPath()
        discPath.addArc(withCenter: center, radius: outerRadius, startAngle: 0, endAngle: .fullCircle, clockwise: true)
        let cutOutPath = UIBezierPath()
        cutOutPath.addArc(withCenter: center, radius: innerRadius, startAngle: 0, endAngle: .fullCircle, clockwise: true)
        discPath.append(cutOutPath.reversing())

        path = discPath.cgPath
        fillColor = color
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
