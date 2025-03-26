import Foundation
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import GoogleAPIClientForREST_Calendar
import SwiftUI

struct Event: Identifiable {
    var id: String
    var title: String
    var date: Date
    var duration: Double
    var type: String
    var createdBy: String
}

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    @Published var googleEvents: [GTLRCalendar_Event] = []
    @Published var isGoogleSignedIn: Bool = false
    private var db = Firestore.firestore()
    private let calendarService = GTLRCalendarService()
    
    init() {
        loadEvents()
        restoreGoogleSignIn()
    }
    
    private func restoreGoogleSignIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error restoring Google Sign In: \(error)")
                        self?.isGoogleSignedIn = false
                        return
                    }
                    
                    print("Successfully restored Google Sign In")
                    self?.isGoogleSignedIn = true
                    self?.loadGoogleCalendarEvents()
                }
            }
        }
    }
    
    func loadEvents() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("events")
            .whereField("createdBy", in: [userId])
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No events found")
                    return
                }
                
                self.events = documents.compactMap { document -> Event? in
                    let data = document.data()
                    return Event(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                        duration: data["duration"] as? Double ?? 1.0,
                        type: data["type"] as? String ?? "",
                        createdBy: data["createdBy"] as? String ?? ""
                    )
                }
            }
    }
    
    func addEvent(_ title: String, date: Date, duration: Double, type: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newEvent = [
            "title": title,
            "date": Timestamp(date: date),
            "duration": duration,
            "type": type,
            "createdBy": userId
        ] as [String : Any]
        
        db.collection("events").addDocument(data: newEvent) { error in
            if let error = error {
                print("Error adding event: \(error)")
            }
        }
    }
    
    func deleteEvent(_ id: String) {
        db.collection("events").document(id).delete() { error in
            if let error = error {
                print("Error removing event: \(error)")
            }
        }
    }
    
    func loadGoogleCalendarEvents() {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            print("Not signed in to Google")
            return
        }
        
        calendarService.authorizer = user.fetcherAuthorizer
        
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        let calendar = Calendar.current
        
        query.timeMin = GTLRDateTime(date: Date())
        if let oneMonthFromNow = calendar.date(byAdding: .month, value: 1, to: Date()) {
            query.timeMax = GTLRDateTime(date: oneMonthFromNow)
        }
        
        query.singleEvents = true
        query.orderBy = "startTime"
        
        print("Fetching Google Calendar events...")
        
        calendarService.executeQuery(query) { [weak self] (ticket, result, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching Google Calendar events: \(error)")
                    return
                }
                
                guard let eventsList = result as? GTLRCalendar_Events else {
                    print("Could not parse events response")
                    return
                }
                
                self?.googleEvents = eventsList.items ?? []
                print("Fetched \(eventsList.items?.count ?? 0) Google Calendar events")
            }
        }
    }
    
    func signInToGoogleCalendar(completion: @escaping (Bool) -> Void) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(false)
            return
        }
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: ["https://www.googleapis.com/auth/calendar.readonly"]
        ) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Google Sign In Error: \(error)")
                    self?.isGoogleSignedIn = false
                    completion(false)
                    return
                }
                
                print("Successfully signed in to Google")
                self?.isGoogleSignedIn = true
                self?.loadGoogleCalendarEvents()
                completion(true)
            }
        }
    }
    
    func signOutGoogle() {
        GIDSignIn.sharedInstance.signOut()
        isGoogleSignedIn = false
        googleEvents.removeAll()
    }
    
    func checkConflicts(for date: Date, duration: Double) -> [(String, Date, String)] {
        let calendar = Calendar.current
        
        guard let endDate = calendar.date(byAdding: .minute, value: Int(duration * 60), to: date) else {
            return []
        }
        
        var conflicts: [(String, Date, String)] = []
        
        // Check local events
        for event in events {
            if let eventEnd = calendar.date(byAdding: .minute, value: Int(event.duration * 60), to: event.date) {
                if date < eventEnd && event.date < endDate {
                    conflicts.append((event.title, event.date, "Local Event"))
                }
            }
        }
        
        // Check Google Calendar events
        for event in googleEvents {
            if let start = event.start?.dateTime?.date ?? event.start?.date?.date,
               let end = event.end?.dateTime?.date ?? event.end?.date?.date {
                if date < end && start < endDate {
                    conflicts.append((event.summary ?? "Untitled Event", start, "Google Calendar"))
                }
            }
        }
        
        return conflicts
    }
}


