import Foundation
import UIKit
import XCTest
@testable import Assets

class ColorsTests: XCTestCase {
    func test_colorsExistInAssetCatalog() {
        for color in Color.allCases {
            let uiColor = UIColor(named: color.rawValue, in: Assets.bundle, compatibleWith: nil)
            XCTAssertNotNil(uiColor, "Asset catalog is missing an entry for \(color.rawValue)")
        }
    }
}
