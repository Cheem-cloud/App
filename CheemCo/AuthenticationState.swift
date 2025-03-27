//
import SwiftUI
import FirebaseAuth

class AuthenticationState: ObservableObject {
    @Published var isAuthenticated = false
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.isAuthenticated = user != nil
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                self.isAuthenticated = true
                completion(true, nil)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                self.isAuthenticated = true
                completion(true, nil)
            }
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        isAuthenticated = false
    }
}


