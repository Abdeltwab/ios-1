import Foundation
import UIKit
import Assets

class TimeLogDayHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier: String = "TimeLogDayHeader"
    static let nib: UINib = UINib(nibName: "TimeLogDayHeader", bundle: Assets.bundle)
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = Color.backgroundPrimary.uiColor
        self.backgroundView = backgroundView
    }
}
