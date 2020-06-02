import Foundation

public enum Either<A, B> {
    case left(A)
    case right(B)
    
    public var left: A? {
        switch self {
        case let .left(value):
            return value
        case .right:
            return nil
        }
    }
    
    public var right: B? {
        switch self {
        case let .right(value):
            return value
        case .left:
            return nil
        }
    }
}

extension Either: Equatable where A: Equatable, B: Equatable { }
