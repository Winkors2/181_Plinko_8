import UIKit
import SwiftUI
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        
    
//        PushExpressManager.shared.requestNotificationsPermission(registerForRemoteNotifications: true)
        
        
        // SwiftUI launch manually
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootView = ContentViewApp()
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }

}
