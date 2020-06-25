import Foundation

public extension Comparable {
    func clamp(min: Self, max: Self) -> Self {
        if self > max {
            return max
        } else if self < min {
            return min
        }

        return self
    }
}
