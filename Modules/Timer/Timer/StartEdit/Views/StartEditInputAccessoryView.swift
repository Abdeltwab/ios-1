import UIKit
import Architecture
import RxSwift
import Assets
import Utils

class StartEditInputAccessoryView: UIToolbar {

    private let billableTooltipDuration: TimeInterval = 2

    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var billableButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = .flexibleHeight
    }

    func bindStore(store: StartEditStore) {
        projectButton.rx.tap
            .mapTo(StartEditAction.projectButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        tagButton.rx.tap
            .mapTo(StartEditAction.tagButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        billableButton.rx.tap
            .do(onNext: showBillableTooltip)
            .mapTo(StartEditAction.billableButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        acceptButton.rx.tap
            .do(onNext: { UIImpactFeedbackGenerator(style: .light).impactOccurred() })
            .mapTo(StartEditAction.doneButtonTapped)
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }

    private func showBillableTooltip() {
        Tooltip.show(from: self.billableButton,
                     text: Strings.billable,
                     duration: self.billableTooltipDuration)
    }
}
