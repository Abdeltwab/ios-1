import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias CalendarDayStore = Store<CalendarDayState, CalendarDayAction>

public class CalendarDayViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Calendar"
    public static var storyboardBundle = Assets.bundle

    private var disposeBag = DisposeBag()

    public var store: CalendarDayStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
}
