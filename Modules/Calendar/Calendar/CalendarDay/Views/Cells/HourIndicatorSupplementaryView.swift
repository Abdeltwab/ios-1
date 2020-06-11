import UIKit
import Assets

public final class HourIndicatorSupplementaryView: UICollectionViewCell {

    static let reuseIdentifier: String = "HourIndicatorSupplementaryView"
    static let nib: UINib = UINib(nibName: "HourIndicatorSupplementaryView", bundle: Assets.bundle)

    @IBOutlet var hourIndicatorLabel: UILabel!
}
