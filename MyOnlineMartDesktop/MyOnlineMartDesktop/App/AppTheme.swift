import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.96, green: 0.94, blue: 0.91)
    static let surface = Color(red: 0.99, green: 0.98, blue: 0.97)
    static let surfaceStrong = Color(red: 0.95, green: 0.93, blue: 0.90)
    static let textPrimary = Color(red: 0.16, green: 0.14, blue: 0.12)
    static let textSecondary = Color(red: 0.42, green: 0.38, blue: 0.34)
    static let accent = Color(red: 0.12, green: 0.53, blue: 0.52)
    static let accentSoft = Color(red: 0.82, green: 0.93, blue: 0.91)
    static let highlight = Color(red: 0.88, green: 0.55, blue: 0.27)
    static let border = Color(red: 0.88, green: 0.85, blue: 0.82)
    static let danger = Color(red: 0.72, green: 0.24, blue: 0.24)

    static let cornerRadius: CGFloat = 16
    static let tightCornerRadius: CGFloat = 12
}

enum AppFont {
    static func display(_ size: CGFloat) -> Font {
        .custom("Avenir Next", size: size).weight(.semibold)
    }

    static func title(_ size: CGFloat) -> Font {
        .custom("Avenir Next", size: size).weight(.medium)
    }

    static func body(_ size: CGFloat) -> Font {
        .custom("Avenir Next", size: size)
    }

    static func caption(_ size: CGFloat) -> Font {
        .custom("Avenir Next", size: size).weight(.regular)
    }
}
