import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Settings", subtitle: "Session and system details.")

            CardContainer {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Signed in as")
                        .font(AppFont.caption(12))
                        .foregroundColor(AppTheme.textSecondary)
                    Text(session.username ?? "Unknown")
                        .font(AppFont.title(16))

                    Divider()

                    Text("Role")
                        .font(AppFont.caption(12))
                        .foregroundColor(AppTheme.textSecondary)
                    Text(session.role?.rawValue ?? "Unknown")
                        .font(AppFont.title(16))

                    Divider()

                    Text("API Base URL")
                        .font(AppFont.caption(12))
                        .foregroundColor(AppTheme.textSecondary)
                    Text(APIService.shared.baseURL.absoluteString)
                        .font(AppFont.body(13))
                        .foregroundColor(AppTheme.textPrimary)
                }
            }

            Button("Sign Out") {
                session.signOut()
            }
            .buttonStyle(SecondaryButtonStyle())

            Spacer()
        }
        .padding(24)
    }
}
