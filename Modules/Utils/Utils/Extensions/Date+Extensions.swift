import Foundation

private let shortTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

private let simpleDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM"
    return formatter
}()

private let encoderDateFormatter: DateFormatter =
{
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
}()

extension Date {
    public func ignoreTimeComponents() -> Date {
        let units: NSCalendar.Unit = [ .year, .month, .day]
        let calendar = Calendar.current
        return calendar.date(from: (calendar as NSCalendar).components(units, from: self))!
    }

    public var roundedToClosestMinute: Date {
        let calendar = Calendar.current
        let secondsInAMinute = calendar.maximumRange(of: .second)!.upperBound
        let seconds = calendar.component(.second, from: self)
        return seconds >= (secondsInAMinute / 2)
            ? calendar.date(byAdding: .second, value: secondsInAMinute - seconds, to: self)!
            : calendar.date(byAdding: .second, value: -seconds, to: self)!
    }
    
    public func toDayString() -> String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        }
        
        return simpleDateFormatter.string(from: self)
    }
    
    public func toTimeString() -> String {
        return shortTimeFormatter.string(from: self)
    }
    
    public func toServerEncodedDateString() -> String {
        return encoderDateFormatter.string(from: self).replacingOccurrences(of: "+0000", with: "+00:00")
    }
}

public extension Date {
    static func with(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int = 0,
        _ minute: Int = 0,
        _ seconds: Int = 0,
        _ timeZone: TimeZone = .current
    ) -> Date {
        DateComponents(calendar: .current, timeZone: timeZone, year: year, month: month, day: day, hour: hour, minute: minute, second: seconds).date!
    }

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
