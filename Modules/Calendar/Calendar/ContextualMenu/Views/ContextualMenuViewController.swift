import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias ContextualMenuStore = Store<ContextualMenuState, ContextualMenuAction>

public class ContextualMenuViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Calendar"
    public static var storyboardBundle = Assets.bundle

    private var disposeBag = DisposeBag()

    public var store: ContextualMenuStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

    }
}
