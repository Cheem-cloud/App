import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            // Background - hunter green gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.13, green: 0.27, blue: 0.12),  // Dark hunter green
                    Color(red: 0.18, green: 0.32, blue: 0.17)   // Lighter hunter green
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Main "C" with integrated "co"
            ZStack {
                // Large C
                Path { path in
                    path.addArc(
                        center: CGPoint(x: 512, y: 512),
                        radius: 300,
                        startAngle: .degrees(-30),
                        endAngle: .degrees(30),
                        clockwise: true
                    )
                    path.addArc(
                        center: CGPoint(x: 512, y: 512),
                        radius: 200,
                        startAngle: .degrees(30),
                        endAngle: .degrees(-30),
                        clockwise: false
                    )
                }
                .stroke(Color.white, lineWidth: 80)
                
                // "co" addition
                Text("co")
                    .font(.system(size: 150, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(x: 120, y: 0)
            }
            // Removed rotation so it appears upright
        }
        .frame(width: 1024, height: 1024)
    }
}

struct AppIcon_Previews: PreviewProvider {
    static var previews: some View {
        AppIcon()
            .previewLayout(.fixed(width: 1024, height: 1024))
    }
}


