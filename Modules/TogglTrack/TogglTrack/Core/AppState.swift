//
//  AppState.swift
//  Toggl-iOS
//
//  Created by Ricardo Sánchez Sotres on 13/02/2020.
//  Copyright © 2020 Ricardo Sánchez Sotres. All rights reserved.
//

import Foundation
import Models
import Architecture
import Onboarding
import Timer
import Utils

enum AppStatus
{
    case unknown
    case foreground
    case background
}

public struct AppState
{
    var appStatus: AppStatus = .unknown
    public var route: AppRoute = .start
    public var user: Loadable<User> = .nothing
    public var entities: TimeLogEntities = TimeLogEntities()
    
    public var localOnboardingState: LocalOnboardingState = LocalOnboardingState()
    public var localTimerState: LocalTimerState = LocalTimerState()
}

// Module specific states
extension AppState: OnboardingState
{
    var onboardingState: OnboardingState
    {
        get {
            self
        }
        set {
            user = newValue.user
            route = newValue.route
            localOnboardingState = newValue.localOnboardingState
        }
    }
}

extension AppState: TimerState
{
    var timerState: TimerState
    {
        get {
            self
        }
        set {
            entities = newValue.entities
            localTimerState = newValue.localTimerState
        }
    }
}
