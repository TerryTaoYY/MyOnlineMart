import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: AppSession

    var body: some View {
        ZStack {
            AppBackground()
            if session.isAuthenticated {
                MainShellView()
            } else {
                AuthRootView()
            }
        }
        .tint(AppTheme.accent)
    }
}
