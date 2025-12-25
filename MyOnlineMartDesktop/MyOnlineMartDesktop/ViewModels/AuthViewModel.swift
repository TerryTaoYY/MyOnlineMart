import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var usernameOrEmail = ""
    @Published var password = ""
    @Published var registerUsername = ""
    @Published var registerEmail = ""
    @Published var registerPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func login(session: AppSession) async {
        guard !usernameOrEmail.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your username or email, plus your password."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await APIService.shared.login(usernameOrEmail: usernameOrEmail, password: password)
            session.signIn(with: response)
        } catch {
            errorMessage = errorMessage(from: error)
        }
    }

    func register(session: AppSession) async {
        guard !registerUsername.isEmpty, !registerEmail.isEmpty, !registerPassword.isEmpty else {
            errorMessage = "Provide a username, email, and password."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await APIService.shared.register(username: registerUsername, email: registerEmail, password: registerPassword)
            session.signIn(with: response)
        } catch {
            errorMessage = errorMessage(from: error)
        }
    }

    private func errorMessage(from error: Error) -> String {
        error.userMessage
    }
}
