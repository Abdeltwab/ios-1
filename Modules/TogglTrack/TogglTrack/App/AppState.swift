import Foundation
import Models
import Architecture
import Onboarding
import Timer
import Calendar
import Utils

public struct AppState {
    public var route: RoutePath = AppRoute.start.path
    public var user: Loadable<User> = .nothing
    public var entities: TimeLogEntities =  TimeLogEntities()
    public var editableTimeEntry: EditableTimeEntry?

    public var localOnboardingState: LocalOnboardingState = LocalOnboardingState()
    public var localTimerState: LocalTimerState = LocalTimerState()
    public var localCalendarState: LocalCalendarState = LocalCalendarState()
}

// Module specific states
extension AppState {
    
    var loadingState: LoadingState {
        get {
            LoadingState(
                entities: entities,
                route: route
            )
        }
        set {
            entities = newValue.entities
            route = newValue.route
        }
    }
    
    var onboardingState: OnboardingState {
        get {
            OnboardingState(
                user: user,
                route: route,
                localOnboardingState: localOnboardingState
            )
        }
        set {
            user = newValue.user
            route = newValue.route
            localOnboardingState = newValue.localOnboardingState
        }
    }
    
    var timerState: TimerState {
        get {
            TimerState(
                user: user,
                entities: entities,
                editableTimeEntry: editableTimeEntry,
                localTimerState: localTimerState
            )
        }
        
        set {
            user = newValue.user
            entities = newValue.entities
            editableTimeEntry = newValue.editableTimeEntry
            localTimerState = newValue.localTimerState
        }
    }

    var calendarState: CalendarState {
        get {
            CalendarState(
                localCalendarState: localCalendarState,
                editableTimeEntry: editableTimeEntry
            )
        }

        set {
            localCalendarState = newValue.localCalendarState
            editableTimeEntry = newValue.editableTimeEntry
        }
    }
}
