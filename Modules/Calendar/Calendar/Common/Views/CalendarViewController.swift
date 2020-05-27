import UIKit
import Assets
import Utils
import Architecture

class CalendarViewController: UIViewController {

    var calendarDayViewController: CalendarDayViewController!

    var store: Store<CalendarState, CalendarAction>!

    override func viewDidLoad() {
        super.viewDidLoad()

        install(calendarDayViewController)
    }
}
