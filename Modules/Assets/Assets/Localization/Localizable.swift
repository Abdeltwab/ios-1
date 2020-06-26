import Foundation

protocol Localizable {
    var localized: String { get }
}

extension String: Localizable {
    public var localized: String { NSLocalizedString(self, bundle: Assets.bundle, comment: "") }
}
