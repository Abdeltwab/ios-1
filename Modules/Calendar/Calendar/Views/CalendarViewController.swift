import UIKit
import Assets
import Utils
import Architecture

class CalendarViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Calendar"
    public static var storyboardBundle = Assets.bundle

    var store: Store<CalendarState, CalendarAction>!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.TabBar.calendar
    }
    
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
