import Foundation

extension Error {
    var userMessage: String {
        if let apiError = self as? APIServiceError {
            return apiError.errorDescription ?? localizedDescription
        }
        return localizedDescription
    }
}
