import UIKit
import Utils
import Assets

class SimpleBottomSheet: UIViewController {

    private let containedViewController: UIViewController

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewController: UIViewController) {
        containedViewController = viewController
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.backgroundCard.uiColor

        install(containedViewController)

        view.layer.cornerRadius = 10
        view.layer.shadowColor = Color.shadow.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -6)
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 0.2
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        guard let parent = parent else { return }

        view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
    }
}
