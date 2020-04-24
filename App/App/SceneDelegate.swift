import UIKit
import TogglTrack
import Firebase
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Analytics

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var togglTrack: TogglTrack!
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        #if !DEBUG
        FirebaseApp.configure()
        MSAppCenter.start("{Our App Secret}", withServices: [MSAnalytics.self, MSCrashes.self])
        #endif
        
        // If we ever want to have multiple windows we should share the store and not create one for every TogglTrack instance
        window = UIWindow(windowScene: windowScene)
        togglTrack = TogglTrack(window: window!, analyticsServices: [FirebaseAnalyticsService(), AppCenterAnalyticsService()])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
