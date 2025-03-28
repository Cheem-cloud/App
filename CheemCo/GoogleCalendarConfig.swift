import Foundation
import GoogleSignIn
import FirebaseCore
import UIKit

enum GoogleCalendarError: Error {
    case configurationFailed
    case noClientID
    case noRootViewController
    case signInFailed(String)
    case noAccessToken
}

class GoogleCalendarConfig {
    static let shared = GoogleCalendarConfig()
    
    private init() {}
    
    var currentUserEmail: String?
    
    func configureGoogleCalendar() throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleCalendarError.noClientID
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func authorizeCalendarAccess(completion: @escaping (Result<String, Error>) -> Void) {
        let scopes = [
            "https://www.googleapis.com/auth/calendar.readonly",
            "https://www.googleapis.com/auth/calendar.events"
        ]
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(.failure(GoogleCalendarError.noRootViewController))
            return
        }
        
        // Use signInWithPresenting to show account picker
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: scopes,
            completion: { result, error in
                if let error = error {
                    completion(.failure(GoogleCalendarError.signInFailed(error.localizedDescription)))
                    return
                }
                
                guard let accessToken = result?.user.accessToken.tokenString else {
                    completion(.failure(GoogleCalendarError.noAccessToken))
                    return
                }
                
                // Store the current user's email
                self.currentUserEmail = result?.user.profile?.email
                
                completion(.success(accessToken))
            }
        )
    }
}
