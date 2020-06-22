import Foundation
import UIKit
import Utils

class ColorOptionCell: UICollectionViewCell {
    @IBOutlet var checkmarkView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _ = contentView.circularView()
    }
    
    var isCurrentColor: Bool {
        get {
            return !checkmarkView.isHidden
        }
        set {
            checkmarkView.isHidden = !newValue
        }
    }
}
