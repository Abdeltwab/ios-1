import Foundation
import UIKit
import Assets

public func projectClientTaskString(projectName: String? = nil,
                                    projectColor: String? = nil,
                                    taskName: String? = nil,
                                    clientName: String? = nil) -> NSAttributedString {
    let attributedString = NSMutableAttributedString()
    
    if let color = projectColor {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "projectCircle", in: Assets.bundle, compatibleWith: nil)!
        let attachmentString = NSAttributedString(attachment: attachment)
        let part = NSMutableAttributedString(attributedString: attachmentString)
        part.addAttribute(.foregroundColor,
                           value: UIColor(hex: color).projectColor,
                           range: NSRange(location: 0, length: attachmentString.length))
        attributedString.append(part)
        
        let spacer = NSTextAttachment()
        spacer.bounds = CGRect(x: 0, y: 0, width: 5, height: 0)
        attributedString.append(NSAttributedString(attachment: spacer))
    }
    
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
