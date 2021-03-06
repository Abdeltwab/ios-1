import RxCocoa
import UIKit
import CoreGraphics

protocol BottomSheetContent: class {
    var scrollView: UIScrollView? { get }
    var smallStateHeight: Driver<CGFloat> { get }
    var visibility: Driver<Bool> { get }
    func loseFocus()
    func focus()
    func dispatchDialogDismissed()
}
