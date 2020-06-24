import Foundation
import Models
import Architecture
import Onboarding
import Timer
import Calendar
import Utils
import CalendarService

public struct AppState {
    public var route: RoutePath = AppRoute.start.path
    public var user: Loadable<User> = .nothing
    public var preferences: Loadable<UserPreferences> = .nothing
    public var entities: TimeLogEntities =  TimeLogEntities()
    public var calendarEvents: [String: CalendarEvent] = [:]
    public var editableTimeEntry: EditableTimeEntry?

    public var calendarPermissionWasGranted = false

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
                localTimerState: localTimerState,
                calendarEvents: calendarEvents
            )
        }
        
        set {
            user = newValue.user
            entities = newValue.entities
            editableTimeEntry = newValue.editableTimeEntry
            localTimerState = newValue.localTimerState
            calendarEvents = newValue.calendarEvents
        }
    }

    var calendarState: CalendarState {
        get {
            CalendarState(
                user: user,
                localCalendarState: localCalendarState,
                calendarEvents: calendarEvents,
                editableTimeEntry: editableTimeEntry
            )
        }

        set {
            user = newValue.user
            localCalendarState = newValue.localCalendarState
            calendarEvents = newValue.calendarEvents
            editableTimeEntry = newValue.editableTimeEntry
        }
    }
}
