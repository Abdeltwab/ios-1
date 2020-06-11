import UIKit
import RxSwift
import RxCocoa
import Assets

public class DurationTextField: UITextField, UITextFieldDelegate {

    private let placeHolderColor = Color.ghostText.uiColor
    private var originalDuration: TimeInterval?
    private var input: DurationTextFieldInfo = .empty
    private var formattedDuration: String = ""
    private let defaultFont = UIFont.monospacedDigitSystemFont(ofSize: 27, weight: .regular)
    private let defaultTintColor = Color.textSecondary.uiColor
    private let defaultTextColor = Color.textPrimary.uiColor
    public var duration: TimeInterval = 0

    public override func awakeFromNib() {
        super.awakeFromNib()

        keyboardType = .numberPad
        adjustsFontSizeToFitWidth = false
        font = defaultFont
        tintColor = defaultTintColor

        delegate = self
    }

    deinit {
        delegate = nil
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false // Disable copy, paste, delete
    }

    public override func caretRect(for position: UITextPosition) -> CGRect {
        return super.caretRect(for: endOfDocument) // Disable cursor movements
    }

    public override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return [UITextSelectionRect()] // Disable text selection
    }

    public func setFormattedDuration(_ durationString: String) {
        formattedDuration = durationString
        if isFirstResponder { return }
        setText(formattedDuration)
    }

    private func setText(_ durationText: String) {
        let result = NSMutableAttributedString(
        string: durationText,
        attributes: [
            .font: defaultFont,
            .foregroundColor: defaultTextColor
        ])

        guard let range = durationText.range(of: "^[0:]*(:|$)", options: .regularExpression) else {
            attributedText = result
            return
        }

        result.addAttribute(.foregroundColor, value: defaultTintColor, range: durationText.nsRange(from: range))

        attributedText = result
    }

    private func tryUpdate(_ nextInput: DurationTextFieldInfo) {
        guard nextInput != input, let originalDuration = originalDuration else { return }

        input = nextInput
        duration = input.isEmpty
            ? originalDuration
            : input.toTimeInterval

        setText(input.toString)
    }

    private func isPressingBackspace(range: NSRange, text: String) -> Bool {
        range.length == 1 && text.count == 0
    }

    // MARK: - Delegate Methods
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        originalDuration = duration
        input = .empty
        setText(input.toString)
    }

    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        setText(formattedDuration)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 1 { return false }

        if isPressingBackspace(range: range, text: string) {
            tryUpdate(input.pop())
        } else if let number = Int(string), number >= 0 && number <= 9 {
            tryUpdate(input.push(digit: number))
        }

        return false
    }
}

public extension Reactive where Base: DurationTextField {
    var duration: ControlProperty<TimeInterval> {
        let source = self.observeWeakly(TimeInterval.self, "duration", options: [.initial, .new])
            // Skip nil values (which in practice does not happen, but KVO observe returns Optional)
            .filter { $0 != nil }.map { $0! }
            .takeUntil(deallocated)

        // `base` is a property of `Reactive` and, here, of type `DurationTextField`
        let observer = Binder(base) { (textField, newDuration: TimeInterval) in
            textField.duration = newDuration
        }

        return ControlProperty(values: source, valueSink: observer)
    }
}
