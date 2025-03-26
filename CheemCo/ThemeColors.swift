import SwiftUI

struct ThemeColors {
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.13, green: 0.27, blue: 0.12),
            Color(red: 0.18, green: 0.32, blue: 0.17)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let darkGreen = Color(red: 0.13, green: 0.27, blue: 0.12)
    static let lightGreen = Color(red: 0.18, green: 0.32, blue: 0.17)
    static let textColor = Color.white
    static let secondaryText = Color.white.opacity(0.7)
}

