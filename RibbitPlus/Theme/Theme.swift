import SwiftUI

struct Theme {
    // Ribbit brand colors
    static let ribbitGreen = Color(red: 0.30, green: 0.78, blue: 0.35)
    static let ribbitGreenDark = Color(red: 0.18, green: 0.55, blue: 0.22)
    static let ribbitGreenLight = Color(red: 0.56, green: 0.93, blue: 0.56)

    // Background colors
    static let backgroundDark = Color(red: 0.07, green: 0.08, blue: 0.10)
    static let backgroundCard = Color(red: 0.11, green: 0.12, blue: 0.15)
    static let backgroundElevated = Color(red: 0.15, green: 0.16, blue: 0.19)

    // Accent colors
    static let accentAmber = Color(red: 1.0, green: 0.76, blue: 0.03)
    static let accentRed = Color(red: 0.94, green: 0.33, blue: 0.31)
    static let accentBlue = Color(red: 0.25, green: 0.61, blue: 0.96)

    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.65)
    static let textTertiary = Color(white: 0.40)

    // Signal strength colors
    static func signalColor(for strength: Double) -> Color {
        switch strength {
        case 0.75...: return ribbitGreen
        case 0.5..<0.75: return accentAmber
        case 0.25..<0.5: return .orange
        default: return accentRed
        }
    }

    // Gradients
    static let ribbitGradient = LinearGradient(
        colors: [ribbitGreen, ribbitGreenDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [backgroundDark, Color(red: 0.05, green: 0.10, blue: 0.08)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let glowGradient = RadialGradient(
        colors: [ribbitGreen.opacity(0.3), .clear],
        center: .center,
        startRadius: 5,
        endRadius: 100
    )
}
