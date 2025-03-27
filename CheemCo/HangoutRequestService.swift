import Foundation
import FirebaseFirestore
import FirebaseAuth

class HangoutRequestService {
    static let shared = HangoutRequestService()
    private let db = Firestore.firestore()
    
    func submitRequest(
        fromPersona: Persona,
        toPersona: Persona,
        type: HangoutRequest.HangoutType,
        time: Date,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let request = HangoutRequest(
            id: UUID().uuidString,
            requesterId: currentUserId,
            requesterName: fromPersona.name,
            receiverId: toPersona.id,
            receiverName: toPersona.name,
            type: type,
            time: time,
            status: .pending,
            timestamp: Date()
        )
        
        do {
            try db.collection("hangoutRequests").document(request.id).setData(from: request)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}
