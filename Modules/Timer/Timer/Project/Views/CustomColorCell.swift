import Foundation
import UIKit

class CustomColorCell: UICollectionViewCell {   
    @IBOutlet var checkmarkView: UIImageView!
    @IBOutlet var lockView: UIImageView!
    
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
