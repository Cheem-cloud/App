import Foundation
import GoogleSignIn
import FirebaseCore
import UIKit

class GoogleCalendarConfig {
    static let shared = GoogleCalendarConfig()
    
    private init() {}
    
    func configureGoogleCalendar() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func authorizeCalendarAccess(completion: @escaping (Result<String, Error>) -> Void) {
        let scopes = ["https://www.googleapis.com/auth/calendar.readonly"]
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: scopes
        ) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let accessToken = result?.user.accessToken.tokenString else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No access token"])))
                return
            }
            
            completion(.success(accessToken))
        }
    }
}
