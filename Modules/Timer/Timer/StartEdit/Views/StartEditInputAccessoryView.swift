import UIKit

class StartEditInputAccessoryView: UIToolbar {

    @IBOutlet weak var projectButton: UIButton!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var billableButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        autoresizingMask = .flexibleHeight
    }
}
