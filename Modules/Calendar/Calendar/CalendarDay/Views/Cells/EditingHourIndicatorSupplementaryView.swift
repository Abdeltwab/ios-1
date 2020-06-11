import UIKit
import Assets

public final class EditingHourIndicatorSupplementaryView: UICollectionViewCell {

    static let reuseIdentifier: String = "EditingHourIndicatorSupplementaryView"
    static let nib: UINib = UINib(nibName: "EditingHourIndicatorSupplementaryView", bundle: Assets.bundle)

    @IBOutlet var hourIndicatorLabel: UILabel!
}
