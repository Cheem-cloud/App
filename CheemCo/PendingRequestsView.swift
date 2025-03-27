import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GoogleAPIClientForREST_Calendar

class PendingRequestsViewModel: ObservableObject {
    @Published var pendingRequests: [HangoutRequest] = []
    private var db = Firestore.firestore()
    
    init() {
        loadPendingRequests()
    }
    
    func loadPendingRequests() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("hangoutRequests")
            .whereField("receiverId", isEqualTo: currentUserId)
            .whereField("status", isEqualTo: "pending")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No pending requests found")
                    return
                }
                
                self?.pendingRequests = documents.compactMap { document -> HangoutRequest? in
                    try? document.data(as: HangoutRequest.self)
                }
                .sorted { $0.timestamp > $1.timestamp }
            }
    }
    
    func approveRequest(_ request: HangoutRequest) {
        // Update request status
        db.collection("hangoutRequests").document(request.id).updateData([
            "status": "approved"
        ]) { error in
            if let error = error {
                print("Error approving request: \(error)")
                return
            }
            
            // Create Google Calendar event
            self.createGoogleCalendarEvent(for: request)
        }
    }
    
    func declineRequest(_ request: HangoutRequest) {
        db.collection("hangoutRequests").document(request.id).updateData([
            "status": "declined"
        ]) { error in
            if let error = error {
                print("Error declining request: \(error)")
            }
        }
    }
    
    private func createGoogleCalendarEvent(for request: HangoutRequest) {
        // This will be implemented when we add Google Calendar integration
        print("Creating calendar event for approved hangout")
    }
}

struct PendingRequestsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PendingRequestsViewModel()
    @State private var showingApprovalAlert = false
    @State private var selectedRequest: HangoutRequest?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.pendingRequests.isEmpty {
                    VStack {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 50))
                            .foregroundColor(ThemeColors.textColor)
                            .padding()
                        
                        Text("No pending requests")
                            .font(.headline)
                            .foregroundColor(ThemeColors.textColor)
                    }
                } else {
                    List {
                        ForEach(viewModel.pendingRequests) { request in
                            RequestCard(request: request)
                                .listRowBackground(ThemeColors.lightGreen)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        selectedRequest = request
                                        showingApprovalAlert = true
                                    } label: {
                                        Label("Approve", systemImage: "checkmark")
                                    }
                                    .tint(.green)
                                }
                                .swipeActions(edge: .leading) {
                                    Button(role: .destructive) {
                                        viewModel.declineRequest(request)
                                    } label: {
                                        Label("Decline", systemImage: "xmark")
                                    }
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Pending Requests")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.textColor)
                }
            }
            .alert("Approve Request?", isPresented: $showingApprovalAlert, presenting: selectedRequest) { request in
                Button("Cancel", role: .cancel) {}
                Button("Approve") {
                    viewModel.approveRequest(request)
                }
            } message: { request in
                Text("This will create a calendar event for \(request.hangoutType.rawValue) with \(request.requesterName)")
            }
        }
    }
}

struct RequestCard: View {
    let request: HangoutRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(ThemeColors.textColor)
                Text(request.requesterName)
                    .font(.headline)
                    .foregroundColor(ThemeColors.textColor)
                Spacer()
                Text(request.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(ThemeColors.secondaryText)
            }
            
            HStack {
                Image(systemName: typeIcon(for: request.hangoutType))
                    .foregroundColor(ThemeColors.textColor)
                Text(request.hangoutType.rawValue)
                    .foregroundColor(ThemeColors.textColor)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(ThemeColors.textColor)
                Text(formatDateTime(request.proposedTime))
                    .foregroundColor(ThemeColors.textColor)
            }
            
            HStack {
                Image(systemName: "hourglass")
                    .foregroundColor(ThemeColors.textColor)
                Text("\(request.duration, format: .number) hours")
                    .foregroundColor(ThemeColors.textColor)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func typeIcon(for type: HangoutType) -> String {
        switch type {
        case .hangout: return "person.2.fill"
        case .walk: return "figure.walk"
        case .dinner: return "fork.knife"
        }
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
