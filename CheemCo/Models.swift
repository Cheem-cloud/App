import Foundation

struct Persona: Identifiable, Codable {
    var id: String
    var emailOwner: String      // The email address that owns this persona
    var name: String            // Name of the persona
    var type: String           // e.g., "Tennis Pro", "Business Woman", "Hiker"
    var description: String
    var profileImage: String?   // URL to profile image
    var interests: [String]
    var preferredActivities: [String]
}


enum HangoutType: String, Codable, CaseIterable {
    case hangout = "Hangout"
    case walk = "Walk"
    case dinner = "Dinner"
    
    var icon: String {
        switch self {
        case .hangout: return "person.2.fill"
        case .walk: return "figure.walk"
        case .dinner: return "fork.knife"
        }
    }
    
    var description: String {
        switch self {
        case .hangout: return "Casual time together"
        case .walk: return "Take a walk together"
        case .dinner: return "Share a meal together"
        }
    }
}

