import Foundation

enum UserRole: String, Codable {
    case buyer = "BUYER"
    case admin = "ADMIN"
}

enum OrderStatus: String, Codable, CaseIterable {
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case canceled = "CANCELED"
}

struct AuthResponse: Decodable {
    let token: String
    let role: UserRole
    let username: String
    let userId: Int
}

struct BuyerProduct: Decodable, Identifiable, Hashable {
    let id: Int
    let description: String
    let retailPrice: Double
}

struct AdminProduct: Decodable, Identifiable, Hashable {
    let id: Int
    let description: String
    let wholesalePrice: Double
    let retailPrice: Double
    let stockQuantity: Int
}

struct OrderSummary: Decodable, Identifiable, Hashable {
    let id: Int
    let placedAt: Date
    let status: OrderStatus
}

struct BuyerOrder: Decodable, Identifiable, Hashable {
    let id: Int
    let placedAt: Date
    let status: OrderStatus
    let items: [BuyerOrderItem]
}

struct BuyerOrderItem: Decodable, Identifiable, Hashable {
    let productId: Int
    let description: String
    let quantity: Int
    let unitRetailPrice: Double

    var id: Int { productId }
}

struct OrderStatusResponse: Decodable, Hashable {
    let orderId: Int
    let status: OrderStatus
}

struct AdminOrderSummary: Decodable, Identifiable, Hashable {
    let id: Int
    let placedAt: Date
    let status: OrderStatus
    let buyerUsername: String
}

struct AdminOrderDetail: Decodable, Identifiable, Hashable {
    let id: Int
    let placedAt: Date
    let status: OrderStatus
    let buyerUsername: String
    let items: [AdminOrderItem]
}

struct AdminOrderItem: Decodable, Identifiable, Hashable {
    let productId: Int
    let description: String
    let quantity: Int
    let unitWholesalePrice: Double
    let unitRetailPrice: Double

    var id: Int { productId }
}

struct BuyerTopFrequentItem: Decodable, Identifiable, Hashable {
    let productId: Int
    let description: String
    let totalQuantity: Int

    var id: Int { productId }
}

struct BuyerTopRecentItem: Decodable, Identifiable, Hashable {
    let productId: Int
    let description: String
    let lastPurchasedAt: Date

    var id: Int { productId }
}

struct AdminProfitSummary: Decodable, Hashable {
    let productId: Int
    let description: String
    let totalProfit: Double
}

struct AdminPopularItem: Decodable, Identifiable, Hashable {
    let productId: Int
    let description: String
    let totalQuantity: Int

    var id: Int { productId }
}

struct AdminTotalSold: Decodable, Hashable {
    let totalItems: Int
}

struct CreateOrderRequest: Encodable {
    let items: [OrderRequestItem]
}

struct OrderRequestItem: Encodable {
    let productId: Int
    let quantity: Int
}

struct AdminProductCreateRequest: Encodable {
    let description: String
    let wholesalePrice: Double
    let retailPrice: Double
    let stockQuantity: Int
}

struct AdminProductUpdateRequest: Encodable {
    let description: String?
    let wholesalePrice: Double?
    let retailPrice: Double?
    let stockQuantity: Int?
}

struct EmptyResponse: Decodable {}

struct APIErrorResponse: Decodable {
    let error: String
    let message: String
    let details: [String]?
    let timestamp: String?
}
