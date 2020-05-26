import UIKit
import Architecture
import Assets
import Timer
import Calendar
import RxSwift

public final class MainCoordinator: TabBarCoordinator {
    private var store: Store<AppState, AppAction>
    private var disposeBag = DisposeBag()
    
    private let timerCoordinator: TimerCoordinator
    private let calendarCoordinator: CalendarCoordinator
    
    public init(
        store: Store<AppState, AppAction>,
        timerCoordinator: TimerCoordinator,
        calendarCoordinator: CalendarCoordinator
    ) {
        self.store = store
        self.timerCoordinator = timerCoordinator
        self.calendarCoordinator = calendarCoordinator
        
        super.init()
        
        tabBarController.rx.didSelect
            .compactMap({ self.tabBarController.viewControllers?.firstIndex(of: $0) })
            .map(AppAction.tabBarTapped)
            .subscribe(onNext: store.dispatch)            
            .disposed(by: disposeBag)
    }
    
    public override func start() {
        
        timerCoordinator.start()
        let timer = timerCoordinator.rootViewController!
        timer.tabBarItem = UITabBarItem(title: Strings.TabBar.timer, image: Images.TabBar.timer, tag: 0)
        
        let reports = UIViewController()
        reports.view.backgroundColor = .orange
        let reportsNav = UINavigationController(rootViewController: reports)
        reportsNav.tabBarItem = UITabBarItem(title: Strings.TabBar.reports, image: Images.TabBar.reports, tag: 1)

        calendarCoordinator.start()
        let calendar = calendarCoordinator.rootViewController!
        calendar.tabBarItem = UITabBarItem(title: Strings.TabBar.calendar, image: Images.TabBar.calendar, tag: 2)

        tabBarController.setViewControllers([timer, reportsNav, calendar], animated: false)
    }
    
    public override func newRoute(route: String) -> Coordinator? {
        
        guard let route = TabBarRoute(rawValue: route) else { fatalError() }

        switch route {
            
        case .timer:
            tabBarController.selectedIndex = 0
            
        case .reports:
            tabBarController.selectedIndex = 1
            
        case .calendar:
            tabBarController.selectedIndex = 2

        }
        
        return nil
    }
}
