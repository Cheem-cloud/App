import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    func addTestUsers() {
        let testUsers = [
            [
                "id": "user1",
                "name": "Kendall Smith",
                "email": "kendall@example.com",
                "fcmToken": "test_token_1"
            ],
            [
                "id": "user2",
                "name": "Alex Johnson",
                "email": "alex@example.com",
                "fcmToken": "test_token_2"
            ],
            [
                "id": "user3",
                "name": "Chris Williams",
                "email": "chris@example.com",
                "fcmToken": "test_token_3"
            ]
        ]
        
        for user in testUsers {
            db.collection("users").document(user["id"] as! String).setData(user) { error in
                if let error = error {
                    print("Error adding test user: \(error)")
                } else {
                    print("Successfully added test user: \(user["name"] ?? "")")
                }
            }
        }
    }
}
