import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.title(14))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.tightCornerRadius))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.title(13))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(AppTheme.surfaceStrong)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.tightCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.tightCornerRadius)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
