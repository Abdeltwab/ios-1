import Foundation
import CoreGraphics
import Darwin

public extension Int {
    static var hoursOnTheClock: Int { 12 }
}

public extension CGFloat {
    static var tau: CGFloat { 2 * .pi }
    static var quarterOfCircle: CGFloat { .tau / 4 }
    static var fullCircle: CGFloat { .tau }
}

public extension Date {
    var angleOnTheDial: CGFloat {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .second], from: self)
        let timeInterval = TimeInterval(components.minute! * .secondsInAMinute + components.second!)
        return timeInterval.angle - .quarterOfCircle
    }
}

public extension TimeInterval {

    var angle: CGFloat { CGFloat(self) / (CGFloat(Int.minutesInAnHour) * CGFloat(Int.secondsInAMinute)) * .fullCircle }

    var positiveAngle: CGFloat {
        var angle = CGFloat(self)
        while angle < 0 {
            angle += .fullCircle
        }
        return angle
    }
}

public extension CGFloat {
    var positiveAngle: CGFloat {
        var angle = CGFloat(self)
        while angle < 0 {
            angle += .fullCircle
        }
        return angle
    }

    func angleToTime() -> TimeInterval {
        let timeInHours = CGFloat(self) / .fullCircle
        let timeinSeconds = timeInHours * CGFloat(Int.minutesInAnHour) * CGFloat(Int.secondsInAMinute)
        return TimeInterval(timeinSeconds)
    }

    func isBetween(startAngle: CGFloat, endAngle: CGFloat) -> Bool {
        let angle = self.positiveAngle
        let positiveStartAngle = startAngle.positiveAngle
        let positiveEndAngle = endAngle.positiveAngle

        if positiveStartAngle > positiveEndAngle {
            return positiveStartAngle <= angle || angle <= positiveEndAngle
        }

        return (positiveStartAngle...positiveEndAngle) ~= angle
    }
}

public extension CGPoint {
    static func pointOnCircumference(center: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
        return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }

    func angle(to otherPoint: CGPoint) -> CGFloat {
        return atan2(self.y - otherPoint.y, self.x - otherPoint.x)
    }

    func distanceSq(to point2: CGPoint) -> CGFloat {
        let deltaX = self.x - point2.x
        let deltaY = self.y - point2.y
        return deltaX * deltaX + deltaY * deltaY
    }
}

public extension Int {
    func pingPongClamp(_ length: Int) -> Int {
        guard length > 0 else { fatalError("The length for clamping must be at positive integer, \(length) given.") }
        guard self >= 0 else { fatalError("The clamped number a non-negative integer, \(self) given.") }

        if length == 1 {
            return 0
        }
            
        let lengthOfFoldedSequence = 2 * length - 2
        let indexInFoldedSequence = self % lengthOfFoldedSequence
        if indexInFoldedSequence < length {
            return indexInFoldedSequence
        }

        return lengthOfFoldedSequence - indexInFoldedSequence
    }
}

public extension Array {
    func getPingPongIndexedItem(_ index: Int) -> Element {
        return self[index.pingPongClamp(count)]
    }
}
