import UIKit
import SwiftUI
import FirebaseCore
import SdkPushExpress

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let PUSHEXPRESS_APP_ID = "43706-1437"
    private var myOwnDatabaseExternalId = UIDevice.current.identifierForVendor?.uuidString ?? ""
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        
        // PushExpress
        try! PushExpressManager.shared.initialize(appId: PUSHEXPRESS_APP_ID, essentialsOnly: true)
//        PushExpressManager.shared.requestNotificationsPermission(registerForRemoteNotifications: true)
        try! PushExpressManager.shared.activate(extId: myOwnDatabaseExternalId)
        
        // SwiftUI launch manually
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootView = ContentViewApp()
        window.rootViewController = UIHostingController(rootView: rootView)
        self.window = window
        window.makeKeyAndVisible()
        
        return true
    }
    func enablePushNotifications() {
            PushExpressManager.shared.requestNotificationsPermission(registerForRemoteNotifications: true)
//            print("🔔 Разрешения на пуши запрошены при открытии WebView")
        }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        PushExpressManager.shared.transportToken = tokenParts.joined()
//        print("✅ APNs токен установлен: \(PushExpressManager.shared.transportToken ?? "nil")")
    }
}
