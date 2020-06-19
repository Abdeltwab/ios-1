import UIKit
import TogglTrack
import Firebase
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Analytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var togglTrack: TogglTrack!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13, *) {
            return true
        }
        
        #if !DEBUG
        FirebaseApp.configure()
        MSAppCenter.start("{Our App Secret}", withServices: [MSAnalytics.self, MSCrashes.self])
        #endif
        
        window = UIWindow(frame: UIScreen.main.bounds)
        togglTrack = TogglTrack(window: window!, analyticsServices: [FirebaseAnalyticsService(), AppCenterAnalyticsService()])
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneDidEnterBackground
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Not called under iOS 13 - See SceneDelegate sceneWillEnterForeground
        togglTrack.appDidBecomeActive()
    }

    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
