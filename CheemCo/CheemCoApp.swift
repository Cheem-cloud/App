import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    let notificationManager = NotificationManager.shared
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct CheemCoApp: App {
    @StateObject private var authState = AuthenticationState()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                ContentView()
                    .environmentObject(authState)
            } else {
                LoginView()
                    .environmentObject(authState)
            }
        }
    }
}
