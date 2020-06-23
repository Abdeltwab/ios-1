import Foundation
import UIKit

public extension UIView {
    func circularView() -> UIView {
        self.layer.cornerRadius = bounds.size.width / 2
        self.layer.masksToBounds = true
        return self
    }
}
