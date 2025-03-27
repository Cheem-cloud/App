// HangoutRequestService.swift

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class HangoutRequestService {
    private let db = Firestore.firestore()
    
    func submitHangoutRequest(
        persona: Persona,
        hangoutType: HangoutType,
        duration: Double,
        proposedTime: Date
    ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: No authenticated user")
            return
        }
        
        // Create a dictionary of the request data
        let requestData: [String: Any] = [
            "userId": userId,
            "personaId": persona.id,
            "hangoutType": hangoutType.rawValue,
            "proposedTime": Timestamp(date: proposedTime),
            "duration": Int(duration * 60), // Convert hours to minutes
            "status": "pending",
            "timestamp": Timestamp(date: Date()),
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
                          let hangoutTypeString = data["hangoutType"] as? String,
                          let hangoutType = HangoutType(rawValue: hangoutTypeString),
                          let proposedTimeTimestamp = data["proposedTime"] as? Timestamp,
                          let duration = data["duration"] as? Int,
                          let status = data["status"] as? String,
                          let timestamp = data["timestamp"] as? Timestamp else {
                        return nil
                    }
                    
                    return HangoutRequest(
                        id: document.documentID,
                        userId: userId,
                        personaId: personaId,
                        hangoutType: hangoutType,
                        proposedTime: proposedTimeTimestamp.dateValue(),
                        duration: duration,
                        status: status,
                        timestamp: timestamp.dateValue()
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

struct HangoutRequest: Identifiable, Decodable {
    let id: String
    let userId: String
    let personaId: String
    let hangoutType: HangoutType
    let proposedTime: Date
    let duration: Int
    let status: String
    let timestamp: Date
    
    var requesterName: String {
        // TODO: Get the actual requester name from the persona
        userId
    }
    
    init(id: String, userId: String, personaId: String, hangoutType: HangoutType, proposedTime: Date, duration: Int, status: String, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.personaId = personaId
        self.hangoutType = hangoutType
        self.proposedTime = proposedTime
        self.duration = duration
        self.status = status
        self.timestamp = timestamp
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case personaId
        case hangoutType
        case proposedTime
        case duration
        case status
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        personaId = try container.decode(String.self, forKey: .personaId)
        hangoutType = try container.decode(HangoutType.self, forKey: .hangoutType)
        proposedTime = try container.decode(Date.self, forKey: .proposedTime)
        duration = try container.decode(Int.self, forKey: .duration)
        status = try container.decode(String.self, forKey: .status)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
    }
}
