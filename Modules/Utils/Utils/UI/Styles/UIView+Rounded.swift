import Foundation
import UIKit

public extension UIView {
    func roundedCorners(radius: CGFloat = 10) -> UIView {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.masksToBounds = true
        return self
    }
}
