import Foundation
import Onboarding
import Timer
import Calendar
import Models
import Analytics

public enum AppAction: Equatable {
    case start
    
    case load(LoadingAction)
    case tabBarTapped(Int)
    
    case onboarding(OnboardingAction)
    case timer(TimerAction)
    case calendar(CalendarAction)
    case startEdit(StartEditAction)
}

extension AppAction {
    
    var load: LoadingAction? {
        get {
            guard case let .load(value) = self else { return nil }
            return value
        }
        set {
            guard case .load = self, let newValue = newValue else { return }
            self = .load(newValue)
        }
    }
    
    var onboarding: OnboardingAction? {
        get {
            guard case let .onboarding(value) = self else { return nil }
            return value
        }
        set {
            guard case .onboarding = self, let newValue = newValue else { return }
            self = .onboarding(newValue)
        }
    }
    
    var timer: TimerAction? {
        get {
            guard case let .timer(value) = self else { return nil }
            return value
        }
        set {
            guard case .timer = self, let newValue = newValue else { return }
            self = .timer(newValue)
        }
    }
    
    var startEdit: StartEditAction? {
        get {
            guard case let .startEdit(value) = self else { return nil }
            return value
        }
        set {
            guard case .startEdit = self, let newValue = newValue else { return }
            self = .startEdit(newValue)
        }
    }

    var calendar: CalendarAction? {
        get {
            guard case let .calendar(value) = self else { return nil }
            return value
        }
        set {
            guard case .calendar = self, let newValue = newValue else { return }
            self = .calendar(newValue)
        }
    }
}

extension AppAction: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .start:
            return "Start"
        case let .load(action):
            return action.debugDescription
        case let .tabBarTapped(tab):
            return "TabSelected: \(tab)"
        case let .onboarding(action):
            return action.debugDescription
        case let .timer(action):
            return action.debugDescription
        case let .calendar(action):
            return action.debugDescription
        case let .startEdit(action):
            return action.debugDescription
        }
    }
}
