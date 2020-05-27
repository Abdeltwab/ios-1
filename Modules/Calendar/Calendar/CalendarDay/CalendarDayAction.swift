import Foundation
import Models

public enum CalendarDayAction: Equatable {
    case dummy
}

extension CalendarDayAction: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {

        case .dummy:
            return "dummy"

        }
    }
}
