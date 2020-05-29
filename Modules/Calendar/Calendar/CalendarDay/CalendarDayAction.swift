import Foundation
import Models

public enum CalendarDayAction: Equatable {
    case startTimeDragged(Date)
}

extension CalendarDayAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .startTimeDragged(let date):
            return "StartTimeDragged: \(date)"
        }
    }
}
