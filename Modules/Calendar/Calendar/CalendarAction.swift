import Foundation

public enum CalendarAction: Equatable {
    case dummyAction
}

extension CalendarAction: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .dummyAction:
            return "DummyAction Delete Me"
        }
    }
}
