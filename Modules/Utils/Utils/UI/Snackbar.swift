import UIKit
import Assets

public final class Snackbar: UIView {

    private let animationDuration: TimeInterval = 0.3
    private let height: CGFloat = 64
    private let bottomMargin: CGFloat = 8

    private static var shared: Snackbar?

    private let text: String
    private let buttonTitle: String?
    private let action: () -> Void

    private init(text: String, buttonTitle: String? = nil, action: @escaping () -> Void = {}) {
        self.text = text
        self.buttonTitle = buttonTitle
        self.action = action
        super.init(frame: .zero)
        createSubviews()
        applyStyles()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20

        let label = UILabel()
        label.text = text
        stackView.addArrangedSubview(label)

        if let buttonTitle = buttonTitle {
            let button = UIButton()
            button.setTitle(buttonTitle, for: .normal)
            button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }

        addSubview(stackView)
        stackView.constraintToParent(constant: 8)
    }

    private func applyStyles() {
        backgroundColor = Color.continueAction.uiColor
        layer.cornerRadius = 8
    }

    @objc
    private func onButtonTapped() {
        action()
        dismiss()
    }

    // MARK: Snackbar's lifecycle

    public func show(in viewController: UIViewController, duration: TimeInterval? = nil) {
        // Dismiss any presented Snackbar
        if let shared = Snackbar.shared {
            shared.dismiss()
        }
        Snackbar.shared = self

        if let duration = duration {
            // Self-destroy after the duration
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: self.destroy)
        }

        // Adds itself to the ViewController's view and sets contraints
        viewController.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -bottomMargin).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true

        // Fade-in animation
        alpha = 0
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { self.alpha = 1 })
    }

    public func dismiss() {
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { self.alpha = 0 },
                       completion: { _ in self.destroy() })
    }

    private func destroy() {
        removeFromSuperview()
        if self == Snackbar.shared {
            Snackbar.shared = nil
        }
    }

    // MARK: Factory method

    static public func with(text: String, buttonTitle: String? = nil, action: @escaping () -> Void = {}) -> Snackbar {
        return Snackbar(text: text, buttonTitle: buttonTitle, action: action)
    }
}
