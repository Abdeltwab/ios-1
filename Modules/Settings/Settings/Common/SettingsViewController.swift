import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias SettingsStore = Store<SettingsState, SettingsAction>

public class SettingsViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Settings"
    public static var storyboardBundle = Assets.bundle

    private var disposeBag = DisposeBag()

    public var store: SettingsStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
}
