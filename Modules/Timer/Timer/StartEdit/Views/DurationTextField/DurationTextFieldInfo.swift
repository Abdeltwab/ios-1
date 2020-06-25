import Foundation

struct DurationTextFieldInfo: Equatable {
    public static let empty: DurationTextFieldInfo = DurationTextFieldInfo(digits: [])
    private let maximumNumberOfDigits: Int = 5
    private static let maximumDuration: TimeInterval = TimeInterval.from(hours: TimerConstants.maxTimeEntryDurationInHours)
    private let digits: [Int]
    public var minutes: Int {
        combineDigitsIntoANumber(0, 2)
    }
    public var hours: Int {
        combineDigitsIntoANumber(2, 3)
    }
    public var isEmpty: Bool {
        digits.isEmpty
    }
    public var toString: String {
        String(format: "%02d:%02d", hours, minutes)
    }
    public var toTimeInterval: TimeInterval {
        TimeInterval.from(hours: hours)
            .advanced(by: TimeInterval.from(minutes: minutes))
            .clamp(min: 0, max: DurationTextFieldInfo.maximumDuration)
    }

    init(digits: [Int]) {
        self.digits = digits
    }

    public static func fromTimeInterval(_ timeInterval: TimeInterval) -> DurationTextFieldInfo {
        var stack = DurationTextFieldInfo.empty
        let totalSeconds = Int(timeInterval.clamp(min: 0, max: maximumDuration))
        let hoursPart = totalSeconds / .secondsInAnHour
        let minutesPart = (totalSeconds / .minutesInAnHour) % .minutesInAnHour
        let digitsString = "\(hoursPart * 100 + minutesPart)"
        digitsString
            .map { String($0) }
            .forEach { digit in stack = stack.push(digit: Int(digit) ?? 0) }
        return DurationTextFieldInfo(digits: stack.digits)
    }

    public func push(digit: Int) -> DurationTextFieldInfo {
        if digit < 0 || digit > 9 {
            fatalError("Digits must be between 0 and 9, value \(digit) was rejected.")
        }

        if digits.count == maximumNumberOfDigits {
            return self
        }

        if digits.isEmpty && digit == 0 {
            return self
        }

        return DurationTextFieldInfo(digits: digits.prepending(digit))
    }

    public func pop() -> DurationTextFieldInfo {
        guard !digits.isEmpty else { return self }
        return DurationTextFieldInfo(digits: digits.removingFirst())
    }

    private func combineDigitsIntoANumber(_ start: Int, _ count: Int) -> Int {
        var number = 0
        var power = 1
        if start >= min(start + count, digits.count) { return number }

        digits[start..<min(start + count, digits.count)].forEach { (digit) in
            number += digit * power
            power *= 10
        }
        return number
    }
}
