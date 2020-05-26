import Foundation
import Architecture
import Timer

func createGlobalReducer() -> Reducer<AppState, AppAction> {
    return Reducer { state, action in
        switch action {
        case .start:
            if state.user.isLoaded {
                state.route = AppRoute.main.path
            } else {
                state.route = AppRoute.onboarding.path
            }
            return []
            
        case let .tabBarTapped(section):
            state.route = [
                TabBarRoute.timer.path,
                TabBarRoute.reports.path,
                TabBarRoute.calendar.path
                ][section]
            return []
            
        case .load, .onboarding, .timer, .startEdit, .calendar:
            return []
        }
    }
}
