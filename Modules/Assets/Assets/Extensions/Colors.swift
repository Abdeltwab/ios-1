import UIKit

public enum Color: String, CaseIterable {
    case backgroundCard = "Background Card"
    case backgroundPrimary = "Background Primary"
    case backgroundSecondary = "Background Secondary"
    case overlay = "Overlay"
    case separator = "Separator"
    case shadow = "Shadow"
    case heading = "Heading"
    case subheading = "Subheading"
    case textPrimary = "Text Primary"
    case textSecondary = "Text Secondary"
    case ghostText = "Ghost Text"
    case startButton = "Start Button"
    case stopButton = "Stop Button"
    case doneButton = "Done Button"
    case continueAction = "Continue Action"
    case deleteAction = "Delete Action"
    case chevron = "Chevron"
    case accent = "Accent"
    case itemActive = "Item Active"
    case itemInactive = "Item Inactive"
    case error = "Error"
    case textIcon = "Text Icon"
    case wheelDigits = "Wheel Digits"
    case wheelInputBackground = "Wheel Input Background"
    case wheelInputBorder = "Wheel Input Border"
    case wheelInputTint = "Wheel Input Tint"
    case wheelThumbTint = "Wheel Thumb Tint"
    case wheelTickMajor = "Wheel Tick Major"
    case wheelTickMinor = "Wheel Tick Minor"
    case noProject = "No Project"
    
    public var uiColor: UIColor {
        UIColor.init(named: self.rawValue, in: Assets.bundle, compatibleWith: nil)!
    }

    public var cgColor: CGColor {
        UIColor.init(named: self.rawValue, in: Assets.bundle, compatibleWith: nil)!.cgColor
    }
}
