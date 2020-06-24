import Foundation
import UIKit

class LogSuggestionCell: UITableViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var projectTaskClientLabel: UILabel!
    @IBOutlet var continueButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = containerView.roundedCorners()
    }
}
