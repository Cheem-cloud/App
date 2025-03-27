// CheemHangView.swift

import SwiftUI

struct CheemHangView: View {
    @State private var showNewRequestView = false
    @State private var showInboxView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("CheemCo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Button(action: {
                    showNewRequestView = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Hangout Request")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    showInboxView = true
                }) {
                    HStack {
                        Image(systemName: "tray.fill")
                        Text("View Inbox")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: NewHangoutRequestView(),
                    isActive: $showNewRequestView
                ) {
                    EmptyView()
                }
            )
            .background(
                NavigationLink(
                    destination: InboxView(),
                    isActive: $showInboxView
                ) {
                    EmptyView()
                }
            )
        }
    }
}

// Placeholder InboxView - implement as needed
struct InboxView: View {
    var body: some View {
        Text("Inbox Coming Soon")
    }
}

struct CheemHangView_Previews: PreviewProvider {
    static var previews: some View {
        CheemHangView()
    }
}
