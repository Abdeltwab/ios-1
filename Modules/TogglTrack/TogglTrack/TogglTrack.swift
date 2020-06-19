import UIKit
import Architecture
import RxSwift
import Onboarding
import API
import Repository
import Networking
import Models
import Utils
import Analytics

public class TogglTrack {
    private let store: Store<AppState, AppAction>!
    private let appCoordinator: AppCoordinator
    private let router: Router
    private var disposeBag = DisposeBag()

    public init(window: UIWindow, analyticsServices: [AnalyticsService]) {

        let appEnvironment = AppEnvironment(analyticsServices: analyticsServices)
        let appFeature = AppFeature(time: appEnvironment.time)
        
        store = Store(
            initialState: AppState(),
            reducer: logging
                <| createAnalyticsReducer(analyticsService: appEnvironment.analytics)
                <| checkFeatureAvailability
                <| createAppReducer(environment: appEnvironment)
        )
        
        appCoordinator = (appFeature.mainCoordinator(store: store) as? AppCoordinator)!
        router = Router(initialCoordinator: appCoordinator)
        
        store.select({ $0 })
            .drive(onNext: { _ in print(">>>>>>>>>>>>>>") })
            .disposed(by: disposeBag)
        
        store
            .select({ $0.route })
            .distinctUntilChanged()
            .do(onNext: { print("Route: \($0)") })
            .drive(onNext: router.navigate)
            .disposed(by: disposeBag)
        
        appCoordinator.start(window: window)
        store.dispatch(.start)                
    }

    public func appDidBecomeActive() {
        store.dispatch(.timer(.logSuggestion(.loadSuggestions)))
    }
}
