import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var fcmToken: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case fcmToken
    }
}

struct HangoutRequest: Identifiable, Codable {
    var id: String
    var requesterId: String
    var requesterName: String
    var receiverId: String
    var receiverName: String
    var hangoutType: HangoutType
    var proposedTime: Date
    var duration: Double
    var status: RequestStatus
    var timestamp: Date
    
    enum HangoutType: String, Codable, CaseIterable {
        case hangout = "Hangout"
        case walk = "Walk"
        case dinner = "Dinner"
    }
    
    enum RequestStatus: String, Codable {
        case pending
        case approved
        case declined
    }
}

class HangoutManager: ObservableObject {
    @Published var pendingRequests: [HangoutRequest] = []
    @Published var users: [User] = []
    private var db = Firestore.firestore()
    
    init() {
        loadUsers()
        loadPendingRequests()
    }
    
    func loadUsers() {
        db.collection("users").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No users found")
                return
            }
            
            self.users = documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            }
        }
    }
    
    func loadPendingRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("hangoutRequests")
            .whereField("receiverId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No pending requests")
                    return
                }
                
                self.pendingRequests = documents.compactMap { document -> HangoutRequest? in
                    try? document.data(as: HangoutRequest.self)
                }
            }
    }
}

struct CheemHangView: View {
    @StateObject private var hangoutManager = HangoutManager()
    @State private var showingNewRequest = false
    @State private var showingPendingRequests = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // New Hangout Request Button
                    Button(action: { showingNewRequest = true }) {
                        HStack {
                            Image(systemName: "person.2.fill")
                            Text("Request New Hangout")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.lightGreen)
                        .foregroundColor(ThemeColors.textColor)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    // Pending Requests Button
                    if !hangoutManager.pendingRequests.isEmpty {
                        Button(action: { showingPendingRequests = true }) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Pending Requests")
                                Spacer()
                                Text("\(hangoutManager.pendingRequests.count)")
                                    .padding(8)
                                    .background(Color.red)
                                    .clipShape(Circle())
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeColors.lightGreen)
                            .foregroundColor(ThemeColors.textColor)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("CheemHang")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingNewRequest) {
                NewHangoutRequestView()
            }
            .sheet(isPresented: $showingPendingRequests) {
                PendingRequestsView()
            }
        }
    }
}

struct CheemHangView_Previews: PreviewProvider {
    static var previews: some View {
        CheemHangView()
    }
}
