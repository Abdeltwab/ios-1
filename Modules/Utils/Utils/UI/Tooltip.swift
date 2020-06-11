import UIKit
import Assets

public class Tooltip: UIView {

    private static var shared = Tooltip()

    private let animationDuration: TimeInterval = 0.3
    private let bottomMargin: CGFloat = 8

    private var timer: Timer?
    private var label: UILabel = UILabel()

    private init() {
        super.init(frame: .zero)
        createSubviews()
        applyStyles()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSubviews() {

        addSubview(label)

        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: topAnchor, constant: 7).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6).isActive = true
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }

    private func applyStyles() {
        backgroundColor = Color.backgroundSecondary.uiColor
        layer.cornerRadius = 8
        layer.shadowColor = Color.shadow.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
    }

    // MARK: - Presentation

    private func show(from view: UIView, text: String, duration: TimeInterval? = nil) {

        timer?.invalidate()

        if let duration = duration {
            timer = Timer(timeInterval: duration, repeats: false) { _ in Tooltip.dismiss() }
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
        }

        label.text = text

        // Adds itself to the view and sets contraints
        view.superview?.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.topAnchor, constant: -bottomMargin).isActive = true

        // Fade-in animation
        alpha = 0
        UIView.animate(withDuration: animationDuration,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { self.alpha = 1 })
    }

    private func destroy() {
        removeFromSuperview()
    }

    static public func show(from view: UIView, text: String, duration: TimeInterval? = nil) {
        if shared.superview != nil {
            shared.destroy()
        }
        shared.show(from: view, text: text, duration: duration)
    }

    public static func dismiss() {
        UIView.animate(withDuration: shared.animationDuration,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { shared.alpha = 0 },
                       completion: { _ in shared.destroy() })
    }
}
