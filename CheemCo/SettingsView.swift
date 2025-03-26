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
    @EnvironmentObject private var authState: AuthenticationState
    @EnvironmentObject private var eventManager: EventManager
    @State private var showingAddUsersConfirmation = false
    @State private var showingAddSingleUser = false
    @State private var addUsersResult = ""
    @State private var isAddingUsers = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                List {
                    Section(header: Text("Account").foregroundColor(ThemeColors.textColor)) {
                        Button(action: {
                            eventManager.signOutGoogle()  // Sign out of Google first
                            authState.signOut()          // Then sign out of Firebase
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                        .listRowBackground(ThemeColors.lightGreen)
                    }
                    
                    if eventManager.isGoogleSignedIn {
                        Section(header: Text("Google Calendar").foregroundColor(ThemeColors.textColor)) {
                            Button(action: {
                                eventManager.signOutGoogle()
                            }) {
                                Text("Disconnect Google Calendar")
                                    .foregroundColor(.orange)
                            }
                            .listRowBackground(ThemeColors.lightGreen)
                        }
                    }
                    
                    Section(header: Text("About").foregroundColor(ThemeColors.textColor)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(ThemeColors.textColor)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(ThemeColors.secondaryText)
                        }
                        .listRowBackground(ThemeColors.lightGreen)
                    }
                    
                    // Debug Section
                    Section(header: Text("Debug Options").foregroundColor(ThemeColors.textColor)) {
                        // Add Single User Button
                        Button(action: {
                            showingAddSingleUser = true
                        }) {
                            HStack {
                                Image(systemName: "person.fill.badge.plus")
                                Text("Add Single Test User")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(ThemeColors.textColor)
                        }
                        .listRowBackground(ThemeColors.lightGreen)
                        
                        // Add Preset Users Button
                        Button(action: {
                            showingAddUsersConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                Text("Add Preset Test Users")
                                Spacer()
                                if isAddingUsers {
                                    ProgressView()
                                } else {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .foregroundColor(ThemeColors.textColor)
                        }
                        .listRowBackground(ThemeColors.lightGreen)
                        
                        if !addUsersResult.isEmpty {
                            Text(addUsersResult)
                                .foregroundColor(addUsersResult.contains("Error") ? .red : .green)
                                .listRowBackground(ThemeColors.lightGreen)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ThemeColors.darkGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingAddSingleUser) {
                AddUserView(addUsersResult: $addUsersResult)
            }
            .alert("Add Preset Test Users", isPresented: $showingAddUsersConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Add Users") {
                    addPresetTestUsers()
                }
            } message: {
                Text("This will add 3 example users to the database. Continue?")
            }
        }
    }
    
    private func addPresetTestUsers() {
        print("addTestUsers function called")
        isAddingUsers = true
        addUsersResult = "Adding users..."
        
        let db = Firestore.firestore()
        let testUsers = [
            [
                "id": "test_user_1",
                "name": "Kendall Smith",
                "email": "kendall@example.com",
                "fcmToken": "test_token_1"
            ] as [String: Any],
            [
                "id": "test_user_2",
                "name": "Alex Johnson",
                "email": "alex@example.com",
                "fcmToken": "test_token_2"
            ] as [String: Any],
            [
                "id": "test_user_3",
                "name": "Chris Williams",
                "email": "chris@example.com",
                "fcmToken": "test_token_3"
            ] as [String: Any]
        ]
        
        print("Starting to add \(testUsers.count) users to Firestore")
        
        for user in testUsers {
            print("Attempting to add user: \(user["name"] ?? "")")
            
            db.collection("users").document(user["id"] as! String).setData(user) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error adding user: \(error.localizedDescription)")
                        addUsersResult = "Error: \(error.localizedDescription)"
                        isAddingUsers = false
                    } else {
                        print("Successfully added user: \(user["name"] ?? "")")
                        addUsersResult = "Added user: \(user["name"] ?? "")"
                    }
                }
            }
        }
        
        // Final confirmation after slight delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            addUsersResult = "Completed adding test users"
            isAddingUsers = false
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthenticationState())
            .environmentObject(EventManager())
    }
}
