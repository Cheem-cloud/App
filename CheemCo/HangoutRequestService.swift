import Foundation
import FirebaseFirestore
import FirebaseAuth

class HangoutRequestService {
    static let shared = HangoutRequestService()
    private let db = Firestore.firestore()
    
    func submitRequest(
        toPersona: Persona,
        type: HangoutType,
        time: Date,
        duration: Double,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let request = HangoutRequest(
            id: UUID().uuidString,
            fromUserId: currentUserId,
            toPersonaId: toPersona.id,
            toUserEmail: toPersona.emailOwner,
            receiverName: toPersona.name,  // Add receiver name
            hangoutType: type,
            proposedTime: time,
            duration: duration,
            status: .pending,
            timestamp: Date(),
            message: nil
        )
        
        do {
            try db.collection("hangoutRequests").document(request.id).setData(from: request)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
