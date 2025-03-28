import Foundation
import GoogleSignIn
import FirebaseCore

class SettingsViewModel: ObservableObject {
    @Published var settings: UserSettings?
    @Published var isLoading = false
    @Published var error: String?
    
    private let calendarService = GoogleCalendarService.shared
    private let defaults = UserDefaults.standard
    private let settingsKey = "userSettings"
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let data = defaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.settings = settings
        }
    }
    
    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: settingsKey)
        }
    }
    
    func connectCalendar(for user: UserSettings.CalendarUser) {
        isLoading = true
        error = nil
        
        GoogleCalendarConfig.shared.authorizeCalendarAccess { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let accessToken):
                    if let email = GoogleCalendarConfig.shared.currentUserEmail {
                        let calendarUser = UserSettings.CalendarUser(
                            email: email,
                            accessToken: accessToken,
                            personas: user.personas,
                            isCalendarAuthorized: true,
                            lastTokenRefresh: Date()
                        )
                        
                        if self?.settings == nil {
                            self?.settings = UserSettings(primaryUser: calendarUser)
                        } else if self?.settings?.secondaryUser == nil {
                            self?.settings?.secondaryUser = calendarUser
                        }
                        
                        self?.saveSettings()
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
    
    func disconnectCalendar(for email: String) {
        if settings?.primaryUser.email == email {
            settings?.primaryUser.isCalendarAuthorized = false
        } else if settings?.secondaryUser?.email == email {
            settings?.secondaryUser?.isCalendarAuthorized = false
        }
        saveSettings()
    }
    
    func inviteSecondaryUser(email: String) {
        // TODO: Implement invitation system
        // This could involve:
        // 1. Sending an email invitation
        // 2. Creating a pending connection
        // 3. Waiting for the secondary user to accept
    }
    
    func refreshCalendarAccess(for email: String) {
        isLoading = true
        error = nil
        
        GoogleCalendarConfig.shared.authorizeCalendarAccess { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let accessToken):
                    if let email = GoogleCalendarConfig.shared.currentUserEmail {
                        if self?.settings?.primaryUser.email == email {
                            self?.settings?.primaryUser.accessToken = accessToken
                            self?.settings?.primaryUser.lastTokenRefresh = Date()
                        } else if self?.settings?.secondaryUser?.email == email {
                            self?.settings?.secondaryUser?.accessToken = accessToken
                            self?.settings?.secondaryUser?.lastTokenRefresh = Date()
                        }
                        self?.saveSettings()
                    }
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
} 