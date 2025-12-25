import SwiftUI

enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Sign In"
    case register = "Create Account"

    var id: String { rawValue }
}

struct AuthRootView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject private var session: AppSession
    @State private var mode: AuthMode = .login

    var body: some View {
        HStack(spacing: 28) {
            AuthBrandPanel()
                .frame(width: 320)

            CardContainer {
                VStack(alignment: .leading, spacing: 20) {
                    Picker("", selection: $mode) {
                        ForEach(AuthMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if mode == .login {
                        AuthLoginForm(viewModel: viewModel, session: session)
                    } else {
                        AuthRegisterForm(viewModel: viewModel, session: session)
                    }
                }
            }
            .frame(width: 360)
        }
        .padding(40)
        .alert("Unable to continue", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

struct AuthBrandPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Super Duper Mart")
                .font(AppFont.display(28))
                .foregroundColor(AppTheme.textPrimary)
            Text("Desktop command center for buyers and sellers.")
                .font(AppFont.body(14))
                .foregroundColor(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                Label("Live product catalog", systemImage: "square.grid.2x2")
                Label("Orders with live status", systemImage: "tray.full")
                Label("Watchlist and insights", systemImage: "heart")
                Label("Admin controls", systemImage: "shield")
            }
            .font(AppFont.body(13))
            .foregroundColor(AppTheme.textPrimary)

            Spacer()

            Text("Powered by your Spring Boot API")
                .font(AppFont.caption(12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .padding(24)
        .frame(maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [AppTheme.surfaceStrong, AppTheme.accentSoft],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

struct AuthLoginForm: View {
    @ObservedObject var viewModel: AuthViewModel
    let session: AppSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Welcome back", subtitle: "Use your username or email to continue.")

            VStack(alignment: .leading, spacing: 10) {
                Text("Username or Email")
                    .font(AppFont.caption(12))
                TextField("buyer1", text: $viewModel.usernameOrEmail)
                    .textFieldStyle(.roundedBorder)
                Text("Password")
                    .font(AppFont.caption(12))
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                Task { await viewModel.login(session: session) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}

struct AuthRegisterForm: View {
    @ObservedObject var viewModel: AuthViewModel
    let session: AppSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Create account", subtitle: "Join the Super Duper Mart experience.")

            VStack(alignment: .leading, spacing: 10) {
                Text("Username")
                    .font(AppFont.caption(12))
                TextField("buyer1", text: $viewModel.registerUsername)
                    .textFieldStyle(.roundedBorder)
                Text("Email")
                    .font(AppFont.caption(12))
                TextField("buyer1@example.com", text: $viewModel.registerEmail)
                    .textFieldStyle(.roundedBorder)
                Text("Password")
                    .font(AppFont.caption(12))
                SecureField("Password", text: $viewModel.registerPassword)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                Task { await viewModel.register(session: session) }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }
}
