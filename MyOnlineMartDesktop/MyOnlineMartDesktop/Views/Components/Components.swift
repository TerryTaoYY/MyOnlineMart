import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.background, AppTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(AppTheme.accentSoft)
                .frame(width: 420, height: 420)
                .offset(x: -240, y: -260)
                .blur(radius: 10)
                .opacity(0.6)

            RoundedRectangle(cornerRadius: 220)
                .fill(AppTheme.surfaceStrong)
                .frame(width: 520, height: 320)
                .rotationEffect(.degrees(-18))
                .offset(x: 260, y: 260)
                .blur(radius: 12)
                .opacity(0.65)
        }
    }
}

struct CardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

struct StatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(AppFont.caption(11))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundColor(labelColor)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .processing:
            return AppTheme.highlight.opacity(0.2)
        case .completed:
            return AppTheme.accentSoft
        case .canceled:
            return AppTheme.danger.opacity(0.15)
        }
    }

    private var labelColor: Color {
        switch status {
        case .processing:
            return AppTheme.highlight
        case .completed:
            return AppTheme.accent
        case .canceled:
            return AppTheme.danger
        }
    }
}

struct PriceTag: View {
    let amount: Double

    var body: some View {
        Text(amount, format: .currency(code: "USD"))
            .font(AppFont.title(14))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(AppTheme.surfaceStrong)
            .clipShape(Capsule())
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let symbol: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 32))
                .foregroundColor(AppTheme.accent)
            Text(title)
                .font(AppFont.title(18))
                .foregroundColor(AppTheme.textPrimary)
            Text(message)
                .font(AppFont.body(14))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: 320)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.display(22))
                .foregroundColor(AppTheme.textPrimary)
            Text(subtitle)
                .font(AppFont.body(13))
                .foregroundColor(AppTheme.textSecondary)
        }
    }
}
