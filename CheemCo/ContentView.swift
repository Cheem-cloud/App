import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authState: AuthenticationState
    @StateObject private var eventManager = EventManager()
    
    init() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor(ThemeColors.darkGreen)
        
        // Set colors for selected and unselected items
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        TabView {
            CheemHangView()
                .tabItem {
                    Label("CheemHang", systemImage: "person.2.fill")
                }
            
            SettingsView()
                .environmentObject(eventManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
