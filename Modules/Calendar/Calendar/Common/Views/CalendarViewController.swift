import UIKit
import Assets
import Utils
import Architecture

class CalendarViewController: UIViewController {

    var calendarDayViewController: CalendarDayViewController!
    var contextualMenuViewController: ContextualMenuViewController!

    var store: Store<CalendarState, CalendarAction>!

    override func viewDidLoad() {
        super.viewDidLoad()

        install(calendarDayViewController)
        install(contextualMenuViewController, customConstraints: true)
    }
}
