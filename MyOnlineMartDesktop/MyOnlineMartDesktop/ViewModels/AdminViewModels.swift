import Foundation
import Combine

@MainActor
final class AdminProductsViewModel: ObservableObject {
    @Published var products: [AdminProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await APIService.shared.adminProducts(token: token)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func create(token: String, request: AdminProductCreateRequest) async -> AdminProduct? {
        do {
            let product = try await APIService.shared.createAdminProduct(token: token, requestBody: request)
            products.append(product)
            return product
        } catch {
            errorMessage = error.userMessage
            return nil
        }
    }

    func update(token: String, productId: Int, request: AdminProductUpdateRequest) async -> AdminProduct? {
        do {
            let product = try await APIService.shared.updateAdminProduct(token: token, productId: productId, requestBody: request)
            if let index = products.firstIndex(where: { $0.id == productId }) {
                products[index] = product
            }
            return product
        } catch {
            errorMessage = error.userMessage
            return nil
        }
    }

    func applyUpdate(_ product: AdminProduct) {
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
        } else {
            products.append(product)
        }
    }
}

@MainActor
final class AdminOrdersViewModel: ObservableObject {
    @Published var orders: [AdminOrderSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var page = 0

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            orders = try await APIService.shared.adminOrders(token: token, page: page)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func changePage(token: String, newPage: Int) async {
        page = max(newPage, 0)
        await load(token: token)
    }

    func complete(token: String, orderId: Int) async {
        do {
            let response = try await APIService.shared.completeAdminOrder(token: token, orderId: orderId)
            updateStatus(orderId: orderId, status: response.status)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func cancel(token: String, orderId: Int) async {
        do {
            let response = try await APIService.shared.cancelAdminOrder(token: token, orderId: orderId)
            updateStatus(orderId: orderId, status: response.status)
        } catch {
            errorMessage = error.userMessage
        }
    }

    private func updateStatus(orderId: Int, status: OrderStatus) {
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index] = AdminOrderSummary(
                id: orders[index].id,
                placedAt: orders[index].placedAt,
                status: status,
                buyerUsername: orders[index].buyerUsername
            )
        }
    }
}

@MainActor
final class AdminOrderDetailViewModel: ObservableObject {
    @Published var order: AdminOrderDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String, orderId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            order = try await APIService.shared.adminOrderDetail(token: token, orderId: orderId)
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class AdminSummaryViewModel: ObservableObject {
    @Published var profitSummary: AdminProfitSummary?
    @Published var popularItems: [AdminPopularItem] = []
    @Published var totalSold: AdminTotalSold?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let profitTask = APIService.shared.adminSummaryProfit(token: token)
            async let popularTask = APIService.shared.adminSummaryPopular(token: token)
            async let totalTask = APIService.shared.adminSummaryTotalSold(token: token)
            let (profit, popular, total) = try await (profitTask, popularTask, totalTask)
            profitSummary = profit
            popularItems = popular
            totalSold = total
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class AdminProductDetailViewModel: ObservableObject {
    @Published var product: AdminProduct?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String, productId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            product = try await APIService.shared.adminProductDetail(token: token, productId: productId)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func update(token: String, productId: Int, request: AdminProductUpdateRequest) async -> AdminProduct? {
        do {
            let updated = try await APIService.shared.updateAdminProduct(token: token, productId: productId, requestBody: request)
            product = updated
            return updated
        } catch {
            errorMessage = error.userMessage
            return nil
        }
    }
}
