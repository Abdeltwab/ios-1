import UIKit
import Architecture
import Models
import RxCocoa
import RxSwift
import Utils
import Assets

typealias TimerStore = Store<TimerState, TimerAction>

class TimerViewController: UIViewController {
    var runningTimeEntryViewController: RunningTimeEntryViewController!
    var startEditBottomSheet: BottomSheetViewController<StartEditViewController>!
    var timeLogViewController: UIViewController!
    var projectBottomSheet: BottomSheetViewController<ProjectViewController>!

    private var runningTimeEntryBottomSheet: SimpleBottomSheet!

    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        install(timeLogViewController)

        runningTimeEntryBottomSheet = SimpleBottomSheet(viewController: runningTimeEntryViewController)
        install(runningTimeEntryBottomSheet, customConstraints: true)
        
        install(startEditBottomSheet, customConstraints: true)
        install(projectBottomSheet, customConstraints: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timeLogViewController.additionalSafeAreaInsets.bottom = runningTimeEntryBottomSheet.view.frame.height
    }
}
