import Foundation
import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UITextView {
    public var cursorPosition: Observable<Int?> {
        return Observable.create({ observer in
            let observation = self.base.observe(\.selectedTextRange) { textField, _ in
                observer.onNext(textField.cursorPosition) }
            return Disposables.create {
                observation.invalidate()
            }
        }).startWith(self.base.cursorPosition)
    }
}
