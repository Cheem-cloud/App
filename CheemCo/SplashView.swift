import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity = 1.0
    @EnvironmentObject private var authState: AuthenticationState
    
    var body: some View {
        if isActive {
            if authState.isAuthenticated {
                ContentView()
            } else {
                LoginView()
            }
        } else {
            ZStack {
                // Hunter green background matching your icon
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.13, green: 0.27, blue: 0.12),
                        Color(red: 0.18, green: 0.32, blue: 0.17)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Center everything in the screen
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        // Logo and text container
                        VStack {
                            // Logo
                            ZStack {
                                // Large C
                                Path { path in
                                    path.addArc(
                                        center: CGPoint(x: geometry.size.width/2, y: 0),
                                        radius: 100,
                                        startAngle: .degrees(-30),
                                        endAngle: .degrees(30),
                                        clockwise: true
                                    )
                                    path.addArc(
                                        center: CGPoint(x: geometry.size.width/2, y: 0),
                                        radius: 70,
                                        startAngle: .degrees(30),
                                        endAngle: .degrees(-30),
                                        clockwise: false
                                    )
                                }
                                .stroke(Color.white, lineWidth: 25)
                                
                                // "co" text
                                Text("co")
                                    .font(.system(size: 50, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .offset(x: geometry.size.width/2 + 40, y: 0)
                            }
                            .frame(width: geometry.size.width, height: 200)
                            
                            // Added tagline
                            Text("Ur hot")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .opacity(0.9)
                        }
                        
                        Spacer()
                    }
                }
                .opacity(opacity)
            }
            .onAppear {
                // Start fade out after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    // Fade out over 0.8 seconds
                    withAnimation(.easeOut(duration: 0.8)) {
                        self.opacity = 0
                    }
                    
                    // Change screen after fade completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}


