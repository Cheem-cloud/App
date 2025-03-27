// HangoutRequestService.swift

import Foundation
import Firebase
import FirebaseFirestore

class HangoutRequestService {
    private let db = Firestore.firestore()
    
    func submitHangoutRequest(
        userId: String,
        personaId: String,
        hangoutType: String,
        proposedTime: Date,
        duration: Int
    ) {
        // Create a dictionary of the request data
        let requestData: [String: Any] = [
            "userId": userId,
            "personaId": personaId,
            "hangoutType": hangoutType,
            "proposedTime": Timestamp(date: proposedTime),
            "duration": duration,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        // Add the document to Firestore
        db.collection("hangoutRequests").addDocument(data: requestData) { error in
            if let error = error {
                print("Error adding hangout request: \(error.localizedDescription)")
            } else {
                print("Hangout request successfully submitted")
            }
        }
    }
    
    func getHangoutRequests(forUserId userId: String, completion: @escaping ([HangoutRequest]) -> Void) {
        db.collection("hangoutRequests")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching hangout requests: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let requests = documents.compactMap { document -> HangoutRequest? in
                    let data = document.data()
                    
                    guard let personaId = data["personaId"] as? String,
                          let hangoutType = data["hangoutType"] as? String,
                          let proposedTimeTimestamp = data["proposedTime"] as? Timestamp,
                          let duration = data["duration"] as? Int,
                          let status = data["status"] as? String else {
                        return nil
                    }
                    
                    return HangoutRequest(
                        id: document.documentID,
                        userId: userId,
                        personaId: personaId,
                        hangoutType: hangoutType,
                        proposedTime: proposedTimeTimestamp.dateValue(),
                        duration: duration,
                        status: status
                    )
                }
                
                completion(requests)
            }
    }
    
    func updateRequestStatus(requestId: String, status: String, completion: @escaping (Bool) -> Void) {
        db.collection("hangoutRequests").document(requestId).updateData(["status": status]) { error in
            if let error = error {
                print("Error updating request status: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}

// Define the HangoutRequest model
struct HangoutRequest {
    let id: String
    let userId: String
    let personaId: String
    let hangoutType: String
    let proposedTime: Date
    let duration: Int
    let status: String
}
