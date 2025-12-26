import SwiftUI

struct BuyerShopView: View {
    @StateObject private var viewModel = BuyerShopViewModel()
    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var cart: CartStore
    @State private var showCart = false

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                header
                searchBar
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if viewModel.filteredProducts.isEmpty {
                    EmptyStateView(title: "No products", message: "Nothing matched your search.", symbol: "magnifyingglass")
                        .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(viewModel.filteredProducts) { product in
                                NavigationLink(value: product) {
                                    ProductCardView(
                                        product: product,
                                        isFavorite: viewModel.watchlistIds.contains(product.id),
                                        onAdd: { cart.add(product: product) },
                                        onToggleFavorite: {
                                            guard let token = session.token else { return }
                                            Task { await viewModel.toggleWatchlist(token: token, productId: product.id) }
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(24)
            .navigationDestination(for: BuyerProduct.self) { product in
                ProductDetailView(product: product)
            }
        }
        .sheet(isPresented: $showCart) {
            CartSheetView()
                .frame(minWidth: 420, minHeight: 420)
        }
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
        .alert("Unable to load products", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            SectionHeader(title: "Shop the mart", subtitle: "Curated essentials, only in-stock items.")
            Spacer()
            Button {
                showCart = true
            } label: {
                Label("Cart \(cart.items.count)", systemImage: "cart")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search products", text: $viewModel.searchQuery)
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.tightCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.tightCornerRadius)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

struct ProductCardView: View {
    let product: BuyerProduct
    let isFavorite: Bool
    let onAdd: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(product.description)
                        .font(AppFont.title(15))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? AppTheme.highlight : AppTheme.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                PriceTag(amount: product.retailPrice)
                Button("Add to Cart", action: onAdd)
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

struct ProductDetailView: View {
    let productId: Int
    let initialProduct: BuyerProduct?
    @StateObject private var viewModel = BuyerProductDetailViewModel()
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var session: AppSession
    @State private var quantity = 1

    init(product: BuyerProduct) {
        productId = product.id
        initialProduct = product
    }

    init(productId: Int) {
        self.productId = productId
        initialProduct = nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let product = viewModel.product ?? initialProduct {
                SectionHeader(title: product.description, subtitle: "Premium pick for your cart.")

                HStack(spacing: 12) {
                    PriceTag(amount: product.retailPrice)
                    Stepper("Qty: \(quantity)", value: $quantity, in: 1...99)
                }

                Button("Add to Cart") {
                    cart.add(product: product, quantity: quantity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Spacer()
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                EmptyStateView(title: "Product unavailable", message: "We could not load this product.", symbol: "cart.badge.questionmark")
            }
        }
        .padding(24)
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, productId: productId)
        }
        .alert("Unable to load product", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
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

struct CartSheetView: View {
    @EnvironmentObject private var cart: CartStore
    @EnvironmentObject private var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var showOrderConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                SectionHeader(title: "Your Cart", subtitle: "Build a single order with multiple items.")
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
            }

            if cart.items.isEmpty {
                EmptyStateView(title: "Cart is empty", message: "Add items from the catalog to place an order.", symbol: "cart")
                    .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(cart.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.description)
                                    .font(AppFont.title(14))
                                Text(item.unitPrice, format: .currency(code: "USD"))
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Stepper("", value: Binding(
                                get: { item.quantity },
                                set: { cart.updateQuantity(productId: item.productId, quantity: $0) }
                            ), in: 1...99)
                            Text("x\(item.quantity)")
                                .frame(width: 40)
                            Button {
                                cart.remove(productId: item.productId)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)

                HStack {
                    Text("Total")
                        .font(AppFont.title(16))
                    Spacer()
                    Text(cart.total, format: .currency(code: "USD"))
                        .font(AppFont.display(18))
                }

                Button {
                    Task {
                        guard let token = session.token else { return }
                        await cart.placeOrder(token: token)
                        if cart.lastOrder != nil {
                            showOrderConfirmation = true
                        }
                    }
                } label: {
                    if cart.isPlacingOrder {
                        ProgressView()
                    } else {
                        Text("Place Order")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
        .alert("Order placed", isPresented: $showOrderConfirmation) {
            Button("OK") {
                cart.lastOrder = nil
                dismiss()
            }
        } message: {
            Text(orderMessage)
        }
        .alert("Unable to place order", isPresented: cartErrorBinding) {
            Button("OK", role: .cancel) { cart.errorMessage = nil }
        } message: {
            Text(cart.errorMessage ?? "Unknown error")
        }
    }

    private var orderMessage: String {
        if let lastOrder = cart.lastOrder {
            return "Order #\(lastOrder.id) is processing. Check Orders for details."
        }
        return "Your order is processing. Check Orders for details."
    }

    private var cartErrorBinding: Binding<Bool> {
        Binding(
            get: { cart.errorMessage != nil },
            set: { if !$0 { cart.errorMessage = nil } }
        )
    }
}

struct BuyerOrdersView: View {
    @StateObject private var viewModel = BuyerOrdersViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Orders", subtitle: "Track every purchase and its status.")
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if viewModel.orders.isEmpty {
                    EmptyStateView(title: "No orders yet", message: "Place your first order to see it here.", symbol: "tray")
                        .frame(maxWidth: .infinity)
                } else {
                    List(viewModel.orders) { order in
                        NavigationLink(value: order) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Order #\(order.id)")
                                        .font(AppFont.title(14))
                                    Text(order.placedAt, format: .dateTime.month().day().hour().minute())
                                        .font(AppFont.caption(12))
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                Spacer()
                                StatusBadge(status: order.status)
                                if order.status == .processing {
                                    Button("Cancel") {
                                        Task {
                                            guard let token = session.token else { return }
                                            await viewModel.cancelOrder(token: token, orderId: order.id)
                                        }
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .padding(24)
            .navigationDestination(for: OrderSummary.self) { order in
                BuyerOrderDetailView(orderId: order.id)
            }
        }
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
        .alert("Unable to load orders", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
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

struct BuyerOrderDetailView: View {
    let orderId: Int
    @StateObject private var viewModel = BuyerOrderDetailViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let order = viewModel.order {
                SectionHeader(title: "Order #\(order.id)", subtitle: "Placed \(order.placedAt.formatted(date: .abbreviated, time: .shortened))")
                HStack(spacing: 12) {
                    StatusBadge(status: order.status)
                    if order.status == .processing {
                        Button("Cancel") {
                            Task {
                                guard let token = session.token else { return }
                                await viewModel.cancelOrder(token: token, orderId: order.id)
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .padding(.bottom, 8)

                List(order.items) { item in
                    NavigationLink {
                        ProductDetailView(productId: item.productId)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.description)
                                    .font(AppFont.title(14))
                                Text(item.unitRetailPrice, format: .currency(code: "USD"))
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text("x\(item.quantity)")
                                .font(AppFont.title(13))
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            } else if viewModel.isLoading {
                ProgressView()
            } else {
                EmptyStateView(title: "Order not found", message: "We could not load this order.", symbol: "exclamationmark.triangle")
            }
        }
        .padding(24)
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, orderId: orderId)
        }
        .alert("Unable to load order", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
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

struct BuyerWatchlistView: View {
    @StateObject private var viewModel = BuyerWatchlistViewModel()
    @EnvironmentObject private var session: AppSession
    @EnvironmentObject private var cart: CartStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Watchlist", subtitle: "Products you want to revisit.")
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if viewModel.products.isEmpty {
                EmptyStateView(title: "Nothing here", message: "Your watchlist is empty.", symbol: "heart")
                    .frame(maxWidth: .infinity)
            } else {
                List(viewModel.products) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.description)
                                .font(AppFont.title(14))
                            Text(product.retailPrice, format: .currency(code: "USD"))
                                .font(AppFont.caption(12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Button("Add to Cart") {
                            cart.add(product: product)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        Button {
                            Task {
                                guard let token = session.token else { return }
                                await viewModel.remove(token: token, productId: product.id)
                            }
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.inset)
            }
        }
        .padding(24)
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
        .alert("Unable to load watchlist", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
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

struct BuyerInsightsView: View {
    @StateObject private var viewModel = BuyerInsightsViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        let maxInsightsCardWidth: CGFloat = 600

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Buyer insights", subtitle: "Your favorites and latest picks.")

                VStack(spacing: 16) {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 3 frequent")
                                .font(AppFont.title(15))
                            if viewModel.topFrequent.isEmpty {
                                Text("No data yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                ForEach(viewModel.topFrequent) { item in
                                    HStack {
                                        Text(item.description)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer()
                                        Text("x\(item.totalQuantity)")
                                            .monospacedDigit()
                                    }
                                    .font(AppFont.body(13))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    //.frame(maxWidth: .infinity, alignment: .leading)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 3 recent")
                                .font(AppFont.title(15))
                            if viewModel.topRecent.isEmpty {
                                Text("No data yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                ForEach(viewModel.topRecent) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.description)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text(item.lastPurchasedAt, format: .dateTime.month().day().hour().minute())
                                            .font(AppFont.caption(11))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: maxInsightsCardWidth)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
        }
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
        .alert("Unable to load insights", isPresented: errorBinding) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
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
