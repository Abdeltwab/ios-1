import UIKit

public extension UIScrollView {

    var isAtTop: Bool {
        contentOffset.y <= 0
    }

    var isAtBottom: Bool {
        contentOffset.y >= contentSize.height - frame.height
    }
}
