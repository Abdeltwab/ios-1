import UIKit
import Utils
import Assets
import Architecture
import RxCocoa
import RxSwift
import RxDataSources
import Models

public typealias ProjectStore = Store<ProjectState, ProjectAction>

public class ProjectViewController: UIViewController, Storyboarded {

    public static var storyboardName = "Project"
    public static var storyboardBundle = Assets.bundle

    // MARK: Layout and navigation subviews
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentScrollView: UIScrollView!

    // MARK: Add project subviews
    @IBOutlet var projectNameTextField: UITextField!
    @IBOutlet var togglePrivateProjectButton: UIButton!
    @IBOutlet var addClientButton: UIButton!
    @IBOutlet var selectWorkspaceButton: UIButton!
    @IBOutlet var selectColorButton: UIButton!

    private var disposeBag = DisposeBag()

    public var store: ProjectStore!

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Project name
        store.compactSelect({ $0.editableProject?.name })
            .drive(projectNameTextField.rx.text)
            .disposed(by: disposeBag)

        projectNameTextField.rx.text.compactMap({ $0 })
            .map(ProjectAction.nameEntered)
            .bind(onNext: store.dispatch)
            .disposed(by: disposeBag)

        // Private project
        store.compactSelect({ $0.editableProject?.isPrivate })
            .drive(onNext: { self.togglePrivateProjectButton.isHighlighted = $0 })
            .disposed(by: disposeBag)

        togglePrivateProjectButton.rx.tap
            .mapTo(ProjectAction.privateProjectSwitchTapped)
            .bind(onNext: store.dispatch)
            .disposed(by: disposeBag)
        
        // Done button
        saveButton.rx.tap
            .mapTo(ProjectAction.doneButtonTapped)
            .bind(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }
}

extension ProjectViewController: BottomSheetContent {
    var scrollView: UIScrollView? {
        return contentScrollView
    }
    
    var smallStateHeight: Driver<CGFloat> {
        return Driver.just(200)
    }
    
    var visibility: Driver<Bool> {
        return store.select({ $0.editableProject != nil })
    }
    
    func loseFocus() {
        projectNameTextField.resignFirstResponder()
    }
    
    func focus() {
        projectNameTextField.becomeFirstResponder()
    }
    
    func dispatchDialogDismissed() {
        store.dispatch(.doneButtonTapped)
    }
}
