import Foundation
import Combine

@MainActor
final class BuyerShopViewModel: ObservableObject {
    @Published var products: [BuyerProduct] = []
    @Published var watchlistIds: Set<Int> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let productsTask = APIService.shared.buyerProducts(token: token)
            async let watchlistTask = APIService.shared.buyerWatchlist(token: token)
            let (products, watchlist) = try await (productsTask, watchlistTask)
            self.products = products
            self.watchlistIds = Set(watchlist.map { $0.id })
        } catch {
            errorMessage = error.userMessage
        }
    }

    func toggleWatchlist(token: String, productId: Int) async {
        do {
            if watchlistIds.contains(productId) {
                try await APIService.shared.removeWatchlist(token: token, productId: productId)
                watchlistIds.remove(productId)
            } else {
                try await APIService.shared.addWatchlist(token: token, productId: productId)
                watchlistIds.insert(productId)
            }
        } catch {
            errorMessage = error.userMessage
        }
    }

    var filteredProducts: [BuyerProduct] {
        guard !searchQuery.isEmpty else { return products }
        return products.filter { $0.description.localizedCaseInsensitiveContains(searchQuery) }
    }
}

@MainActor
final class BuyerOrdersViewModel: ObservableObject {
    @Published var orders: [OrderSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            orders = try await APIService.shared.buyerOrders(token: token)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func cancelOrder(token: String, orderId: Int) async {
        do {
            let response = try await APIService.shared.cancelBuyerOrder(token: token, orderId: orderId)
            if let index = orders.firstIndex(where: { $0.id == orderId }) {
                orders[index] = OrderSummary(id: orders[index].id, placedAt: orders[index].placedAt, status: response.status)
            }
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class BuyerOrderDetailViewModel: ObservableObject {
    @Published var order: BuyerOrder?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String, orderId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            order = try await APIService.shared.buyerOrderDetail(token: token, orderId: orderId)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func cancelOrder(token: String, orderId: Int) async {
        do {
            let response = try await APIService.shared.cancelBuyerOrder(token: token, orderId: orderId)
            if let existing = order {
                order = BuyerOrder(
                    id: existing.id,
                    placedAt: existing.placedAt,
                    status: response.status,
                    items: existing.items
                )
            }
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class BuyerWatchlistViewModel: ObservableObject {
    @Published var products: [BuyerProduct] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await APIService.shared.buyerWatchlist(token: token)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func remove(token: String, productId: Int) async {
        do {
            try await APIService.shared.removeWatchlist(token: token, productId: productId)
            products.removeAll { $0.id == productId }
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class BuyerInsightsViewModel: ObservableObject {
    @Published var topFrequent: [BuyerTopFrequentItem] = []
    @Published var topRecent: [BuyerTopRecentItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let frequentTask = APIService.shared.buyerTopFrequent(token: token)
            async let recentTask = APIService.shared.buyerTopRecent(token: token)
            let (frequent, recent) = try await (frequentTask, recentTask)
            topFrequent = frequent
            topRecent = recent
        } catch {
            errorMessage = error.userMessage
        }
    }
}

@MainActor
final class BuyerProductDetailViewModel: ObservableObject {
    @Published var product: BuyerProduct?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String, productId: Int) async {
        isLoading = true
        defer { isLoading = false }
        do {
            product = try await APIService.shared.buyerProductDetail(token: token, productId: productId)
        } catch {
            errorMessage = error.userMessage
        }
    }
}
