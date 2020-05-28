import UIKit
import Architecture
import RxSwift
import RxCocoa

class DatePickers: UIView {

    private let datePickerHeight: CGFloat = 230

    @IBOutlet weak var startDateContainer: UIView!
    @IBOutlet weak var stopDateContainer: UIView!

    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var stopDateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerContainerHeight: NSLayoutConstraint!

    private var disposeBag = DisposeBag()

    func bindStore(store: StartEditStore) {
        startDateButton.rx.tap
            .mapTo(StartEditAction.startButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        stopDateButton.rx.tap
            .mapTo(StartEditAction.stopButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        datePicker.rx.date
            .mapTo({ StartEditAction.dateTimePicked($0) })
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        Driver.combineLatest(
            store.select({ $0.dateTimePickMode }),
            store.select({ $0.editableTimeEntry })
            )
            .drive(onNext: self.setDatePickerMode)
            .disposed(by: disposeBag)
    }
    
    private func setDatePickerMode(mode: DateTimePickMode, editableTimeEntry: EditableTimeEntry?) {

        self.datePickerContainerHeight.constant = mode == .none ? 0 : self.datePickerHeight
        UIView.animate(withDuration: 0.225, delay: 0, options: .curveEaseInOut, animations: {
            // we need to layout both the stack view and the scroll view
            self.superview?.superview?.layoutIfNeeded()
            self.superview?.layoutIfNeeded()
        })

        guard let editableTimeEntry = editableTimeEntry else { return }
        switch mode {
        case .start:
            guard let start = editableTimeEntry.start else { break }
            datePicker.date = start
            datePicker.minimumDate = editableTimeEntry.minStart
            datePicker.maximumDate = editableTimeEntry.maxStart
        case .stop:
            guard let stop = editableTimeEntry.stop else { break }
            datePicker.date = stop
            datePicker.minimumDate = editableTimeEntry.minStop
            datePicker.maximumDate = editableTimeEntry.maxStop
        case .none: break
        }
    }
}

extension DatePickers: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else { return true }
        if view.isDescendant(of: startDateContainer) || view.isDescendant(of: stopDateContainer) {
            return false
        }
        return true
    }
}
