import Foundation
import Architecture
import Onboarding
import Timer
import Calendar
import OtherServices

func createAppReducer(environment: AppEnvironment) -> Reducer<AppState, AppAction> {
    return combine(
        createGlobalReducer(),
        createOnboardingReducer(userAPI: environment.userAPI).pullback(state: \.onboardingState, action: \.onboarding),
        createTimerReducer(
            repository: environment.repository,
            time: environment.time,
            schedulerProvider: environment.schedulerProvider
        ).pullback(state: \.timerState, action: \.timer),
        createCalendarReducer(repository: environment.repository, time: environment.time)
            .pullback(state: \.calendarState, action: \.calendar),
        createLoadingReducer(repository: environment.repository)
            .pullback(state: \.loadingState, action: \.load)
    )
}

public class AppFeature: BaseFeature<AppState, AppAction> {

    private let time: Time

    let features: [String: BaseFeature<AppState, AppAction>]

    init(time: Time) {
        self.time = time
        features = [
            AppRoute.onboarding.rawValue: OnboardingFeature()
                .view { $0.view(
                        state: { $0.onboardingState },
                        action: { AppAction.onboarding($0) })
                },
            AppRoute.main.rawValue: TimerFeature(time: time)
                .view { $0.view(
                        state: { $0.timerState },
                        action: { AppAction.timer($0) })
                },
            TabBarRoute.calendar.rawValue: CalendarFeature(time: time)
                .view { $0.view(
                        state: { $0.calendarState },
                        action: { AppAction.calendar($0) })
                }
        ]
    }

    public override func mainCoordinator(store: Store<AppState, AppAction>) -> Coordinator {

        let mainCoordinator = MainCoordinator(
            store: store,
            timerCoordinator: (features[AppRoute.main.rawValue]!.mainCoordinator(store: store) as? TimerCoordinator)!,
            calendarCoordinator: (features[TabBarRoute.calendar.rawValue]!.mainCoordinator(store: store) as? CalendarCoordinator)!
        )
        return AppCoordinator(
            store: store,
            onboardingCoordinator: features[AppRoute.onboarding.rawValue]!.mainCoordinator(store: store),
            tabBarCoordinator: mainCoordinator
        )
    }
}
