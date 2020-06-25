import Foundation
import UIKit
import Assets

class TimeLogSuggestionsFooter: UITableViewHeaderFooterView {
    
    static let reuseIdentifier: String = "TimeLogSuggestionsFooter"
    static let nib: UINib = UINib(nibName: "TimeLogSuggestionsFooter", bundle: Assets.bundle)

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let text = titleLabel.text {
            titleLabel.text = text.uppercased()
        }
        let backgroundView = UIView(frame: bounds)
        backgroundView.backgroundColor = Color.backgroundPrimary.uiColor
        self.backgroundView = backgroundView
    }
}
