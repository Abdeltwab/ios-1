import UIKit
import Assets

public final class CurrentTimeSupplementaryView: UICollectionViewCell {

    static let reuseIdentifier: String = "CurrentTimeSupplementaryView"
    static let nib: UINib = UINib(nibName: "CurrentTimeSupplementaryView", bundle: Assets.bundle)

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
    }
}
