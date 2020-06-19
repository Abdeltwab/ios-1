import UIKit
import Utils
import Models

class AutocompleteSuggestionCell: BaseTableViewCell<AutocompleteSuggestion> {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    open override func configure(with model: AutocompleteSuggestion) {

        switch model {
        case let .timeEntrySuggestion(timeEntry):
            label.text = timeEntry.description
        case let .projectSuggestion(project):
            label.text = project.name
        case let .taskSuggestion(task, _):
            label.text = task.name
        case let .tagSuggestion(tag):
            label.text = tag.name
        case let .createProjectSuggestion(name):
            label.text = "Create project: \(name)"
        case let .createTagSuggestion(name):
            label.text = "Create tag: \(name)"
        }
    }
}
