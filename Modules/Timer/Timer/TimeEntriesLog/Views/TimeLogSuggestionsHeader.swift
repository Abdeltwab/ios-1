import Foundation
import UIKit
import Assets

class TimeLogSuggestionsHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier: String = "TimeLogSuggestionsHeader"
    static let nib: UINib = UINib(nibName: "TimeLogSuggestionsHeader", bundle: Assets.bundle)
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let text = titleLabel.text {
            titleLabel.text = text.uppercased()
        }
        backgroundView?.backgroundColor = Color.backgroundPrimary.uiColor
    }
}
