import Foundation
import UIKit

public extension UIView {
    func bordered(with color: UIColor, width: Int) -> UIView {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask

        let border = CAShapeLayer()
        self.layer.addSublayer(border)

        border.frame = self.bounds
        let pathUsingCorrectInsetIfAny =
            UIBezierPath(roundedRect: border.bounds, cornerRadius: self.layer.cornerRadius)

        border.path = pathUsingCorrectInsetIfAny.cgPath
        border.fillColor = UIColor.clear.cgColor
        border.strokeColor = color.cgColor
        border.lineWidth = CGFloat(width) * 2
        
        return self
    }
}
