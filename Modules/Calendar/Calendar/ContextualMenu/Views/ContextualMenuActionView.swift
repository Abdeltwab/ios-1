import UIKit
import Assets

@IBDesignable
class ContextualMenuButtonView: UIButton {

    private let iconBackgroundWidth: CGFloat = 40
    private let spacing: CGFloat = 8

    private var iconView: UIImageView!
    private var buttonNameLabel: UILabel!
    private var iconBackgroundView: UIView!

    @IBInspectable var iconImage: UIImage!
    @IBInspectable var iconBackgroundColor: UIColor!
    @IBInspectable var localizedButtonName: String!

    public override var intrinsicContentSize: CGSize { CGSize(width: 120, height: 90) }

    public override func awakeFromNib() {
        super.awakeFromNib()

        iconView = UIImageView()
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = iconImage

        iconBackgroundView = UIView()
        iconBackgroundView.isUserInteractionEnabled = false
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconBackgroundView.backgroundColor = iconBackgroundColor

        buttonNameLabel = UILabel()
        buttonNameLabel.isUserInteractionEnabled = false
        buttonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonNameLabel.textAlignment = .center
        buttonNameLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        buttonNameLabel.textColor = Color.textPrimary.uiColor
        buttonNameLabel.numberOfLines = 0
        buttonNameLabel.text = localizedButtonName.localized

        buildView()
    }

    private func buildView() {
        addSubview(iconBackgroundView)
        addSubview(buttonNameLabel)
        iconBackgroundView.addSubview(iconView)

        iconBackgroundView.layer.cornerRadius = iconBackgroundWidth / 2
        NSLayoutConstraint.activate([
            iconBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: iconBackgroundWidth),
            iconBackgroundView.heightAnchor.constraint(equalTo: iconBackgroundView.widthAnchor),
            iconBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            buttonNameLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: spacing),
            buttonNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
