import Foundation

private struct EmptyBody: Encodable {}

final class APIService {
    static let shared = APIService(baseURL: URL(string: "http://localhost:8080")!)

    let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            if let timestamp = try? container.decode(Double.self) {
                if timestamp > 1_000_000_000_000 {
                    return Date(timeIntervalSince1970: timestamp / 1000)
                }
                return Date(timeIntervalSince1970: timestamp)
            }
            if let timestamp = try? container.decode(Int.self) {
                if timestamp > 1_000_000_000_000 {
                    return Date(timeIntervalSince1970: Double(timestamp) / 1000)
                }
                return Date(timeIntervalSince1970: Double(timestamp))
            }
            let value = try container.decode(String.self)
            if let date = AppDateParser.parse(value) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(value)")
        }
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable {
            let username: String
            let email: String
            let password: String
        }
        let body = Body(username: username, email: email, password: password)
        return try await request(path: "/api/auth/register", method: "POST", token: nil, body: body)
    }

    func login(usernameOrEmail: String, password: String) async throws -> AuthResponse {
        struct Body: Encodable {
            let usernameOrEmail: String
            let password: String
        }
        let body = Body(usernameOrEmail: usernameOrEmail, password: password)
        return try await request(path: "/api/auth/login", method: "POST", token: nil, body: body)
    }

    func buyerProducts(token: String) async throws -> [BuyerProduct] {
        try await request(path: "/api/buyer/products", method: "GET", token: token)
    }

    func buyerProductDetail(token: String, productId: Int) async throws -> BuyerProduct {
        try await request(path: "/api/buyer/products/\(productId)", method: "GET", token: token)
    }

    func createOrder(token: String, items: [OrderRequestItem]) async throws -> BuyerOrder {
        let body = CreateOrderRequest(items: items)
        return try await request(path: "/api/buyer/orders", method: "POST", token: token, body: body)
    }

    func buyerOrders(token: String) async throws -> [OrderSummary] {
        try await request(path: "/api/buyer/orders", method: "GET", token: token)
    }

    func buyerOrderDetail(token: String, orderId: Int) async throws -> BuyerOrder {
        try await request(path: "/api/buyer/orders/\(orderId)", method: "GET", token: token)
    }

    func cancelBuyerOrder(token: String, orderId: Int) async throws -> OrderStatusResponse {
        try await request(path: "/api/buyer/orders/\(orderId)/cancel", method: "PATCH", token: token)
    }

    func buyerTopFrequent(token: String) async throws -> [BuyerTopFrequentItem] {
        try await request(path: "/api/buyer/orders/top/frequent", method: "GET", token: token)
    }

    func buyerTopRecent(token: String) async throws -> [BuyerTopRecentItem] {
        try await request(path: "/api/buyer/orders/top/recent", method: "GET", token: token)
    }

    func buyerWatchlist(token: String) async throws -> [BuyerProduct] {
        try await request(path: "/api/buyer/watchlist", method: "GET", token: token)
    }

    func addWatchlist(token: String, productId: Int) async throws {
        let _: EmptyResponse = try await request(path: "/api/buyer/watchlist/\(productId)", method: "POST", token: token)
    }

    func removeWatchlist(token: String, productId: Int) async throws {
        let _: EmptyResponse = try await request(path: "/api/buyer/watchlist/\(productId)", method: "DELETE", token: token)
    }

    func adminProducts(token: String) async throws -> [AdminProduct] {
        try await request(path: "/api/admin/products", method: "GET", token: token)
    }

    func adminProductDetail(token: String, productId: Int) async throws -> AdminProduct {
        try await request(path: "/api/admin/products/\(productId)", method: "GET", token: token)
    }

    func createAdminProduct(token: String, requestBody: AdminProductCreateRequest) async throws -> AdminProduct {
        try await request(path: "/api/admin/products", method: "POST", token: token, body: requestBody)
    }

    func updateAdminProduct(token: String, productId: Int, requestBody: AdminProductUpdateRequest) async throws -> AdminProduct {
        try await request(path: "/api/admin/products/\(productId)", method: "PATCH", token: token, body: requestBody)
    }

    func adminOrders(token: String, page: Int) async throws -> [AdminOrderSummary] {
        let queryItems = [URLQueryItem(name: "page", value: String(page))]
        return try await request(path: "/api/admin/orders", method: "GET", token: token, queryItems: queryItems)
    }

    func adminOrderDetail(token: String, orderId: Int) async throws -> AdminOrderDetail {
        try await request(path: "/api/admin/orders/\(orderId)", method: "GET", token: token)
    }

    func completeAdminOrder(token: String, orderId: Int) async throws -> OrderStatusResponse {
        try await request(path: "/api/admin/orders/\(orderId)/complete", method: "PATCH", token: token)
    }

    func cancelAdminOrder(token: String, orderId: Int) async throws -> OrderStatusResponse {
        try await request(path: "/api/admin/orders/\(orderId)/cancel", method: "PATCH", token: token)
    }

    func adminSummaryProfit(token: String) async throws -> AdminProfitSummary {
        try await request(path: "/api/admin/summary/profit", method: "GET", token: token)
    }

    func adminSummaryPopular(token: String) async throws -> [AdminPopularItem] {
        try await request(path: "/api/admin/summary/popular", method: "GET", token: token)
    }

    func adminSummaryTotalSold(token: String) async throws -> AdminTotalSold {
        try await request(path: "/api/admin/summary/total-sold", method: "GET", token: token)
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        token: String?,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        try await request(path: path, method: method, token: token, queryItems: queryItems, body: Optional<EmptyBody>.none)
    }

    private func request<T: Decodable, Body: Encodable>(
        path: String,
        method: String,
        token: String?,
        queryItems: [URLQueryItem] = [],
        body: Body?
    ) async throws -> T {
        let sanitizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        guard var components = URLComponents(url: baseURL.appendingPathComponent(sanitizedPath), resolvingAgainstBaseURL: false) else {
            throw APIServiceError.invalidURL
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if let body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            if httpResponse.statusCode == 204 {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw APIServiceError.decoding
            }
            if data.isEmpty, T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIServiceError.decoding
            }
        default:
            if let apiError = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIServiceError.server(message: apiError.message, code: httpResponse.statusCode, details: apiError.details)
            }
            throw APIServiceError.server(message: "Request failed.", code: httpResponse.statusCode, details: nil)
        }
    }
}

enum APIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decoding
    case server(message: String, code: Int, details: [String]?)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid service URL."
        case .invalidResponse:
            return "Unexpected response from the server."
        case .decoding:
            return "Could not read the server response."
        case .server(let message, let code, let details):
            var output = "\(message) (\(code))"
            if let details, !details.isEmpty {
                output += "\n" + details.joined(separator: "\n")
            }
            return output
        }
    }
}
