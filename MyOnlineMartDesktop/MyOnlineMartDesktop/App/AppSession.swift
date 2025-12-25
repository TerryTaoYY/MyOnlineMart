import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var token: String?
    @Published private(set) var role: UserRole?
    @Published private(set) var username: String?
    @Published private(set) var userId: Int?

    private let defaults = UserDefaults.standard

    init() {
        token = defaults.string(forKey: SessionKeys.token)
        if let roleValue = defaults.string(forKey: SessionKeys.role) {
            role = UserRole(rawValue: roleValue)
        } else {
            role = nil
        }
        username = defaults.string(forKey: SessionKeys.username)
        let savedUserId = defaults.integer(forKey: SessionKeys.userId)
        userId = savedUserId == 0 ? nil : savedUserId
    }

    var isAuthenticated: Bool {
        if let token, !token.isEmpty {
            return true
        }
        return false
    }

    func signIn(with response: AuthResponse) {
        token = response.token
        role = response.role
        username = response.username
        userId = response.userId

        defaults.set(response.token, forKey: SessionKeys.token)
        defaults.set(response.role.rawValue, forKey: SessionKeys.role)
        defaults.set(response.username, forKey: SessionKeys.username)
        defaults.set(response.userId, forKey: SessionKeys.userId)
    }

    func signOut() {
        token = nil
        role = nil
        username = nil
        userId = nil

        defaults.removeObject(forKey: SessionKeys.token)
        defaults.removeObject(forKey: SessionKeys.role)
        defaults.removeObject(forKey: SessionKeys.username)
        defaults.removeObject(forKey: SessionKeys.userId)
    }
}

private enum SessionKeys {
    static let token = "session.token"
    static let role = "session.role"
    static let username = "session.username"
    static let userId = "session.userId"
}
