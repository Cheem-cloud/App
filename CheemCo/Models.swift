import Foundation

struct UserSettings: Codable {
    var primaryUser: CalendarUser
    var secondaryUser: CalendarUser?
    
    struct CalendarUser: Codable {
        let email: String
        var accessToken: String
        let personas: [Persona]
        var isCalendarAuthorized: Bool
        var lastTokenRefresh: Date?
    }
}

struct Persona: Identifiable, Codable, Equatable {
    var id: String
    var emailOwner: String      // The email address that owns this persona
    var name: String            // Name of the persona
    var type: String           // e.g., "Tennis Pro", "Business Woman", "Hiker"
    var description: String
    var profileImage: String?   // URL to profile image
    var interests: [String]
    var preferredActivities: [String]
    
    static func == (lhs: Persona, rhs: Persona) -> Bool {
        lhs.id == rhs.id
    }
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

// Add this extension to your existing Persona struct
extension Persona {
    static let examples = [
        Persona(
            id: "1",
            emailOwner: "kendall.m.crocker@gmail.com",
            name: "Tennis Pro Kendall",
            type: "Tennis Pro",
            description: "Professional tennis player and instructor",
            interests: ["Tennis", "Fitness", "Competition"],
            preferredActivities: ["Tennis Match", "Training Session"]
        ),
        Persona(
            id: "2",
            emailOwner: "kendall.m.crocker@gmail.com",
            name: "Business Kendall",
            type: "Business Woman",
            description: "Corporate executive and mentor",
            interests: ["Business", "Networking", "Leadership"],
            preferredActivities: ["Coffee Meeting", "Lunch", "Mentoring"]
        ),
        Persona(
            id: "3",
            emailOwner: "kendall.m.crocker@gmail.com",
            name: "Hiker Kendall",
            type: "Outdoor Enthusiast",
            description: "Adventure seeker and nature lover",
            interests: ["Hiking", "Photography", "Nature"],
            preferredActivities: ["Trail Hiking", "Nature Walk", "Photography"]
        )
    ]
}

