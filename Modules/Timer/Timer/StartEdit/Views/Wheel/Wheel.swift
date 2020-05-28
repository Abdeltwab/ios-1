import UIKit
import Architecture
import RxSwift

class Wheel: UIView {

    @IBOutlet weak var wheelForegroundView: WheelForegroundView!
    @IBOutlet weak var wheelDurationView: UIView!
    @IBOutlet weak var wheelDurationLabelTextField: DurationTextField!

    private var disposeBag = DisposeBag()
    private var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()

        wheelDurationView.layer.cornerRadius = 16
    }

    func bindStore(store: StartEditStore) {
        wheelForegroundView.rx.controlEvent(.valueChanged)
            .mapTo({ _ in StartEditAction.wheelStartAndDurationChanged(self.wheelForegroundView.startTime, self.wheelForegroundView.duration) })
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        wheelDurationLabelTextField.rx.duration
            .mapTo({ StartEditAction.wheelDurationChanged($0) })
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }

    func setDurationString(_ string: String?) {
        wheelDurationLabelTextField.setFormattedDuration(string ?? "00:00")
    }
}
