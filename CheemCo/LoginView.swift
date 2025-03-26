import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var authState: AuthenticationState
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                ThemeColors.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Family Scheduler")
                        .font(.largeTitle)
                        .foregroundColor(ThemeColors.textColor)
                        .padding()
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .padding(.horizontal)
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.textColor))
                    }
                    
                    Button(action: handleLogin) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeColors.lightGreen)
                            .foregroundColor(ThemeColors.textColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    Button(action: handleSignUp) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ThemeColors.darkGreen)
                            .foregroundColor(ThemeColors.textColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading)
                }
                .padding()
            }
        }
    }
    
    private func handleLogin() {
        isLoading = true
        showError = false
        
        authState.signIn(email: email, password: password) { success, error in
            isLoading = false
            if !success {
                showError = true
                errorMessage = error ?? "Unknown error occurred"
            }
        }
    }
    
    private func handleSignUp() {
        isLoading = true
        showError = false
        
        authState.signUp(email: email, password: password) { success, error in
            isLoading = false
            if !success {
                showError = true
                errorMessage = error ?? "Unknown error occurred"
            }
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(ThemeColors.textColor.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(ThemeColors.textColor)
            .accentColor(ThemeColors.textColor)
    }
}


