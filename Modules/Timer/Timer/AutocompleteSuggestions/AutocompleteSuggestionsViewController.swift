import UIKit
import Assets
import Utils
import Models
import Architecture

class AutocompleteSuggestionsViewController: UIViewController, Storyboarded {

    private let rowHeight: CGFloat = 50

    public static var storyboardName = "Timer"
    public static var storyboardBundle = Assets.bundle

    public var store: StartEditStore!

    @IBOutlet weak var tableView: UITableView!
    private var heightConstraint: NSLayoutConstraint!

    private var suggestions = [AutocompleteSuggestion]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        tableView.rowHeight = rowHeight // This might need to be calculated dynamically to support dynamic typing
        tableView.dataSource = self
        tableView.delegate = self
        
        // Initial value set to whatever. This will adapt to the table view content height
        heightConstraint = view.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.priority = UILayoutPriority.defaultLow
        heightConstraint.isActive = true

        view.layer.cornerRadius = 10
        view.clipsToBounds = true
    }

    static func create(in parent: UIViewController, attachedTo attachedView: UIView) -> AutocompleteSuggestionsViewController {
        let suggestionsViewController = self.instantiate()

        parent.install(suggestionsViewController, customConstraints: true)
        suggestionsViewController.view.leadingAnchor.constraint(equalTo: parent.view.leadingAnchor).isActive = true
        suggestionsViewController.view.trailingAnchor.constraint(equalTo: parent.view.trailingAnchor).isActive = true

        let attachedViewRect = attachedView.superview!.convert(attachedView.frame, to: parent.view)
        if attachedViewRect.minY > parent.view.frame.height - attachedView.frame.maxY - parent.view.safeAreaInsets.bottom {
            suggestionsViewController.view.topAnchor.constraint(
                greaterThanOrEqualTo: parent.view.safeAreaLayoutGuide.topAnchor, constant: 20
            ).isActive = true
            suggestionsViewController.view.bottomAnchor.constraint(equalTo: attachedView.topAnchor).isActive = true
        } else {
            suggestionsViewController.view.topAnchor.constraint(equalTo: attachedView.bottomAnchor).isActive = true
            suggestionsViewController.view.bottomAnchor.constraint(
                lessThanOrEqualTo: parent.view.safeAreaLayoutGuide.bottomAnchor, constant: -20
            ).isActive = true
        }

        parent.view.layoutIfNeeded()

        return suggestionsViewController
    }

    func show(_ suggestions: [AutocompleteSuggestion]) {

        self.suggestions = suggestions
        tableView.reloadData()
        heightConstraint.constant = CGFloat(suggestions.count) * rowHeight

        UIView.animate(withDuration: 0.1) {
            self.view.superview?.layoutIfNeeded()
        }
    }

    func hideAndDestroy() {
        heightConstraint.constant = 0
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.view.superview?.layoutIfNeeded()
        },
            completion: { _ in
                self.uninstall()
        })
    }
}

extension AutocompleteSuggestionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AutocompleteSuggestionCell.identifier,
            for: indexPath) as? AutocompleteSuggestionCell else { fatalError() }
        cell.configure(with: suggestions[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let suggestion = suggestions[indexPath.row]
        store.dispatch(StartEditAction.autocompleteSuggestionTapped(suggestion))
    }
}
