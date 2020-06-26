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
    @IBOutlet var colorSelectionCollectionView: UICollectionView!
    @IBOutlet var customProjectColor: UIView!
    @IBOutlet var customColorView: UIView!
    @IBOutlet var customColorPicker: HueSaturationPickerView!

    private var disposeBag = DisposeBag()
    private let defaultCustomColor = UIColor(hex: "3178be")

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

        // Project color
        setUpColors()

        customColorPicker.rx.controlEvent(.valueChanged)
            .mapTo({ _ in ProjectAction.colorPicked(self.customColorPicker.selectedColor.hex) })
            .subscribe(onNext: store.dispatch)
            .disposed(by: disposeBag)

        store.compactSelect({ $0.editableProject?.color })
            .drive(onNext: {
                guard !self.customProjectColor.isHidden else { return }
                self.customColorView.backgroundColor = Project.defaultColors.contains($0)
                    ? self.defaultCustomColor
                    : UIColor(hex: $0)
            })
            .disposed(by: disposeBag)

        // Done button
        saveButton.rx.tap
            .mapTo(ProjectAction.doneButtonTapped)
            .bind(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        _ = selectColorButton.circularView()
            .bordered(with: Color.backgroundCard.uiColor, width: 3)
            .bordered(with: Color.textPrimary.uiColor, width: 1)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        colorSelectionCollectionView.reloadData()
    }

    private func setUpColors() {
        store.compactSelect({ $0.editableProject?.color })
            .map { UIColor(hex: $0).projectColor }
            .drive(onNext: { self.selectColorButton.backgroundColor = $0 })
            .disposed(by: disposeBag)

        store.compactSelect({ $0.editableProject?.color })
            .map(generateColorOptions)
            .asObservable()
            .bind(to: colorSelectionCollectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                switch element {
                case let .default(color, isSelected: selected):
                    guard let cell = collectionView
                        .dequeueReusableCell(withReuseIdentifier: "ColorOptionCell",
                                             for: indexPath) as? ColorOptionCell else { fatalError("Wrong cell type") }
                    cell.contentView.backgroundColor = UIColor(hex: color).projectColor
                    cell.isCurrentColor = selected
                    return cell
                case .custom:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColorCell", for: indexPath)
                    return cell
                }
            }
            .disposed(by: disposeBag)

        colorSelectionCollectionView.rx.modelSelected(ColorOptionViewModel.self)
            .compactMap { colorOption in
                if case let .default(color, isSelected: _) = colorOption {
                    self.customProjectColor.isHidden = true
                    return color
                } else {
                    self.customProjectColor.isHidden = false
                    return nil
                }
            }
            .mapTo(ProjectAction.colorPicked)
            .bind(onNext: store.dispatch)
            .disposed(by: disposeBag)
    }

    private func generateColorOptions(_ color: String) -> [ColorOptionViewModel] {
        Project.defaultColors.map { ColorOptionViewModel.default($0, isSelected: $0 == color) }
            .appending(ColorOptionViewModel.custom(isSelected: false))
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
