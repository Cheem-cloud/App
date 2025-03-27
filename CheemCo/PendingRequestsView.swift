import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import GoogleAPIClientForREST_Calendar

class PendingRequestsViewModel: ObservableObject {
    @Published var pendingRequests: [HangoutRequest] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    init() {
        loadPendingRequests()
    }
    
    func loadPendingRequests() {
        isLoading = true
        
        db.collection("hangoutRequests")
            .whereField("status", isEqualTo: "pending")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.pendingRequests = []
                    return
                }
                
                self.pendingRequests = documents.compactMap { document -> HangoutRequest? in
                    let data = document.data()
                    
                    guard let userId = data["userId"] as? String,
                          let personaId = data["personaId"] as? String,
                          let hangoutTypeRaw = data["hangoutType"] as? String,
                          let hangoutType = HangoutType(rawValue: hangoutTypeRaw),
                          let proposedTimeTimestamp = data["proposedTime"] as? Timestamp,
                          let duration = data["duration"] as? Int,
                          let status = data["status"] as? String,
                          let timestampValue = data["timestamp"] as? Timestamp else {
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
                        timestamp: timestampValue.dateValue()
                    )
                }
            }
    }
    
    func approveRequest(_ request: HangoutRequest) {
        updateRequestStatus(request, status: "approved")
    }
    
    func declineRequest(_ request: HangoutRequest) {
        updateRequestStatus(request, status: "declined")
    }
    
    private func updateRequestStatus(_ request: HangoutRequest, status: String) {
        db.collection("hangoutRequests").document(request.id).updateData([
            "status": status
        ]) { [weak self] error in
            if let error = error {
                self?.error = error
            } else {
                self?.loadPendingRequests()
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
    @State private var selectedRequest: HangoutRequest?
    @State private var showingAlert = false
    @State private var alertAction: AlertAction?
    
    enum AlertAction {
        case approve
        case decline
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.pendingRequests.isEmpty {
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
                                    Button(role: .destructive) {
                                        selectedRequest = request
                                        alertAction = .decline
                                        showingAlert = true
                                    } label: {
                                        Label("Decline", systemImage: "xmark.circle")
                                    }
                                    
                                    Button {
                                        selectedRequest = request
                                        alertAction = .approve
                                        showingAlert = true
                                    } label: {
                                        Label("Approve", systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)
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
            .alert(isPresented: $showingAlert) {
                if let request = selectedRequest, let action = alertAction {
                    Alert(
                        title: Text(action == .approve ? "Approve Request" : "Decline Request"),
                        message: Text(action == .approve ? 
                                   "Are you sure you want to approve this request?" :
                                   "Are you sure you want to decline this request?"),
                        primaryButton: .default(Text(action == .approve ? "Approve" : "Decline")) {
                            if action == .approve {
                                viewModel.approveRequest(request)
                            } else {
                                viewModel.declineRequest(request)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                } else {
                    Alert(title: Text("Error"), message: Text("Something went wrong"))
                }
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
            
            Text(request.hangoutType.rawValue)
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
            
            Text("Duration: \(request.duration / 60) hours")
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
        }
        .padding()
    }
}
