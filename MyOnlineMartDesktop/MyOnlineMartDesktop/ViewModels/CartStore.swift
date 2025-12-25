import Foundation
import Combine

struct CartItem: Identifiable, Hashable {
    let productId: Int
    let description: String
    let unitPrice: Double
    var quantity: Int

    var id: Int { productId }
    var subtotal: Double { unitPrice * Double(quantity) }
}

@MainActor
final class CartStore: ObservableObject {
    @Published private(set) var items: [CartItem] = []
    @Published var isPlacingOrder = false
    @Published var lastOrder: BuyerOrder?
    @Published var errorMessage: String?

    var total: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    func add(product: BuyerProduct, quantity: Int = 1) {
        guard quantity > 0 else { return }
        if let index = items.firstIndex(where: { $0.productId == product.id }) {
            items[index].quantity += quantity
        } else {
            let item = CartItem(productId: product.id, description: product.description, unitPrice: product.retailPrice, quantity: quantity)
            items.append(item)
        }
    }

    func updateQuantity(productId: Int, quantity: Int) {
        guard let index = items.firstIndex(where: { $0.productId == productId }) else { return }
        items[index].quantity = max(quantity, 1)
    }

    func remove(productId: Int) {
        items.removeAll { $0.productId == productId }
    }

    func clear() {
        items.removeAll()
    }

    func placeOrder(token: String) async {
        guard !items.isEmpty else {
            errorMessage = "Add at least one item before placing an order."
            return
        }
        isPlacingOrder = true
        defer { isPlacingOrder = false }
        do {
            let requestItems = items.map { OrderRequestItem(productId: $0.productId, quantity: $0.quantity) }
            let order = try await APIService.shared.createOrder(token: token, items: requestItems)
            lastOrder = order
            clear()
        } catch {
            errorMessage = error.userMessage
        }
    }
}
