import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @Binding var addUsersResult: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("User Details")) {
                        TextField("Name", text: $name)
                            .textFieldStyle(CustomTextFieldStyle())
                        TextField("Email", text: $email)
                            .textFieldStyle(CustomTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Test User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ThemeColors.textColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addSingleUser()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                    .foregroundColor(ThemeColors.textColor)
                }
            }
        }
    }
    
    private func addSingleUser() {
        let db = Firestore.firestore()
        let userId = "test_user_\(UUID().uuidString.prefix(8))"
        
        let userData: [String: Any] = [
            "id": userId,
            "name": name,
            "email": email,
            "fcmToken": "test_token_\(userId)"
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                addUsersResult = "Error adding user: \(error.localizedDescription)"
            } else {
                addUsersResult = "Successfully added user: \(name)"
            }
            dismiss()
        }
    }
}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if let settings = viewModel.settings {
                    Section("Connected Calendars") {
                        ForEach(getConnectedCalendars(settings), id: \.email) { user in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(user.email)
                                        .font(.headline)
                                    Spacer()
                                    if user.isCalendarAuthorized {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                
                                if user.isCalendarAuthorized {
                                    if let lastRefresh = user.lastTokenRefresh {
                                        Text("Last refreshed: \(lastRefresh.formatted())")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Button("Refresh Access") {
                                            viewModel.refreshCalendarAccess(for: user.email)
                                        }
                                        .buttonStyle(.bordered)
                                        
                                        Button("Disconnect") {
                                            viewModel.disconnectCalendar(for: user.email)
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.red)
                                    }
                                } else {
                                    Button("Connect Calendar") {
                                        viewModel.connectCalendar(for: user)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    Section {
                        Button("Add Another Calendar") {
                            viewModel.connectCalendar(for: UserSettings.CalendarUser(
                                email: "",
                                accessToken: "",
                                personas: [],
                                isCalendarAuthorized: false,
                                lastTokenRefresh: nil
                            ))
                        }
                    }
                } else {
                    Section {
                        Button("Connect Primary Calendar") {
                            viewModel.connectCalendar(for: UserSettings.CalendarUser(
                                email: "",
                                accessToken: "",
                                personas: [],
                                isCalendarAuthorized: false,
                                lastTokenRefresh: nil
                            ))
                        }
                    }
                }
            }
            .navigationTitle("Calendar Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
        }
    }
    
    private func getConnectedCalendars(_ settings: UserSettings) -> [UserSettings.CalendarUser] {
        var calendars: [UserSettings.CalendarUser] = []
        
        // Add primary user if exists
        if !settings.primaryUser.email.isEmpty {
            calendars.append(settings.primaryUser)
        }
        
        // Add secondary user if exists
        if let secondaryUser = settings.secondaryUser, !secondaryUser.email.isEmpty {
            calendars.append(secondaryUser)
        }
        
        return calendars
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationState())
            .environmentObject(EventManager())
    }
}
