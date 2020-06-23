import Foundation
import UIKit
import Assets

public func projectClientTaskString(projectName: String? = nil,
                             projectColor: String? = nil,
                             taskName: String? = nil,
                             clientName: String? = nil) -> NSAttributedString {
    let attributedString = NSMutableAttributedString()
    if let project = projectName, let color = projectColor {
        var string = project
        if let task = taskName {
            string += ": \(task)"
        }
        let part = NSAttributedString.init(string: string,
                                           attributes: [.foregroundColor: UIColor(hex: color).projectColor])
        attributedString.append(part)
    }

    if let client = clientName {
        let string = " · \(client)"
        let part = NSAttributedString.init(string: string,
                                           attributes: [.foregroundColor: Color.ghostText.uiColor])
        attributedString.append(part)
    }

    return attributedString
}
