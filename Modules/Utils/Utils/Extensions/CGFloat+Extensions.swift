import CoreGraphics

public extension CGFloat {

    func clamp(_ range: ClosedRange<CGFloat>) -> CGFloat {
        return range.lowerBound > self ? range.lowerBound
            : range.upperBound < self ? range.upperBound
            : self
    }
}
