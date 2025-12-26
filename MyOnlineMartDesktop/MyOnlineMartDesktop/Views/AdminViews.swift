import SwiftUI

struct AdminDashboardView: View {
    @StateObject private var summaryModel = AdminSummaryViewModel()
    @StateObject private var ordersModel = AdminOrdersViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        let metricCardMinHeight: CGFloat = 96

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(title: "Admin dashboard", subtitle: "Monitor orders, stock, and sales health.")

                    HStack(alignment: .top, spacing: 16) {
                        HStack(alignment: .top, spacing: 16) {
                            CardContainer {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Top profit")
                                        .font(AppFont.title(15))
                                    if let summary = summaryModel.profitSummary {
                                        Text(summary.description)
                                            .font(AppFont.body(13))
                                            .lineLimit(2)
                                        Text(summary.totalProfit, format: .currency(code: "USD"))
                                            .font(AppFont.display(18))
                                    } else {
                                        Text("No data yet")
                                            .font(AppFont.caption(12))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: metricCardMinHeight, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity)

                            CardContainer {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Total sold")
                                        .font(AppFont.title(15))
                                    if let totalSold = summaryModel.totalSold {
                                        Text("\(totalSold.totalItems) items")
                                            .font(AppFont.display(18))
                                    } else {
                                        Text("No data yet")
                                            .font(AppFont.caption(12))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: metricCardMinHeight, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)

                        CardContainer {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Top products")
                                    .font(AppFont.title(15))
                                if summaryModel.popularItems.isEmpty {
                                    Text("No data yet")
                                        .font(AppFont.caption(12))
                                        .foregroundColor(AppTheme.textSecondary)
                                } else {
                                    ForEach(summaryModel.popularItems.prefix(3)) { item in
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
                            .frame(maxWidth: .infinity, minHeight: metricCardMinHeight, alignment: .topLeading)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent orders")
                                .font(AppFont.title(16))
                            if ordersModel.orders.isEmpty {
                                Text("No orders yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                ForEach(ordersModel.orders.prefix(5)) { order in
                                    HStack(alignment: .center, spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Order #\(order.id)")
                                                .font(AppFont.body(13))
                                            Text(order.buyerUsername)
                                                .font(AppFont.caption(11))
                                                .foregroundColor(AppTheme.textSecondary)
                                            Text(order.placedAt, format: .dateTime.month().day().hour().minute())
                                                .font(AppFont.caption(11))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }
                                        Spacer()
                                        StatusBadge(status: order.status)
                                        NavigationLink("View", value: order)
                                            .buttonStyle(SecondaryButtonStyle())
                                        if order.status == .processing {
                                            Button("Complete") {
                                                Task {
                                                    guard let token = session.token else { return }
                                                    await ordersModel.complete(token: token, orderId: order.id)
                                                }
                                            }
                                            .buttonStyle(PrimaryButtonStyle())
                                            Button("Cancel") {
                                                Task {
                                                    guard let token = session.token else { return }
                                                    await ordersModel.cancel(token: token, orderId: order.id)
                                                }
                                            }
                                            .buttonStyle(SecondaryButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .padding(24)
                .navigationDestination(for: AdminOrderSummary.self) { order in
                    AdminOrderDetailView(orderId: order.id)
                }
            }
        }
        .task {
            guard let token = session.token else { return }
            await summaryModel.load(token: token)
            await ordersModel.load(token: token)
        }
        .alert("Unable to update orders", isPresented: orderErrorBinding) {
            Button("OK", role: .cancel) { ordersModel.errorMessage = nil }
        } message: {
            Text(ordersModel.errorMessage ?? "Unknown error")
        }
    }

    private var orderErrorBinding: Binding<Bool> {
        Binding(
            get: { ordersModel.errorMessage != nil },
            set: { if !$0 { ordersModel.errorMessage = nil } }
        )
    }
}

struct AdminProductsView: View {
    @StateObject private var viewModel = AdminProductsViewModel()
    @EnvironmentObject private var session: AppSession
    @State private var editorMode: ProductEditorMode?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SectionHeader(title: "Product listings", subtitle: "Manage descriptions, pricing, and inventory.")
                    Spacer()
                    Button("Add Product") {
                        editorMode = .create
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if viewModel.products.isEmpty {
                    EmptyStateView(title: "No products", message: "Create your first listing.", symbol: "shippingbox")
                        .frame(maxWidth: .infinity)
                } else {
                    List(viewModel.products) { product in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.description)
                                    .font(AppFont.title(14))
                                Text("Wholesale \(product.wholesalePrice, format: .currency(code: "USD"))")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("Retail \(product.retailPrice, format: .currency(code: "USD"))")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text("Stock \(product.stockQuantity)")
                                .font(AppFont.body(13))
                            NavigationLink("View", value: product)
                                .buttonStyle(SecondaryButtonStyle())
                            Button("Edit") {
                                editorMode = .edit(product)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(.vertical, 6)
                    }
                    .listStyle(.inset)
                }
            }
            .padding(24)
            .navigationDestination(for: AdminProduct.self) { product in
                AdminProductDetailView(productId: product.id, initialProduct: product) { updated in
                    viewModel.applyUpdate(updated)
                }
            }
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
        .sheet(item: $editorMode) { mode in
            ProductEditorView(mode: mode) { values in
                Task {
                    guard let token = session.token else { return }
                    switch mode {
                    case .create:
                        let request = AdminProductCreateRequest(
                            description: values.description,
                            wholesalePrice: values.wholesalePrice,
                            retailPrice: values.retailPrice,
                            stockQuantity: values.stockQuantity
                        )
                        _ = await viewModel.create(token: token, request: request)
                    case .edit(let product):
                        let request = AdminProductUpdateRequest(
                            description: values.description,
                            wholesalePrice: values.wholesalePrice,
                            retailPrice: values.retailPrice,
                            stockQuantity: values.stockQuantity
                        )
                        _ = await viewModel.update(token: token, productId: product.id, request: request)
                    }
                }
            }
            .frame(minWidth: 420, minHeight: 360)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

struct AdminOrdersView: View {
    @StateObject private var viewModel = AdminOrdersViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SectionHeader(title: "Orders", subtitle: "Review processing orders and finalize them.")
                    Spacer()
                    HStack(spacing: 8) {
                        Button("Prev") {
                            guard let token = session.token else { return }
                            Task { await viewModel.changePage(token: token, newPage: viewModel.page - 1) }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        Text("Page \(viewModel.page + 1)")
                            .font(AppFont.caption(12))
                        Button("Next") {
                            guard let token = session.token else { return }
                            Task { await viewModel.changePage(token: token, newPage: viewModel.page + 1) }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else if viewModel.orders.isEmpty {
                    EmptyStateView(title: "No orders", message: "Orders will appear once buyers start shopping.", symbol: "tray")
                        .frame(maxWidth: .infinity)
                } else {
                    ordersListView
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationDestination(for: AdminOrderSummary.self) { order in
                AdminOrderDetailView(orderId: order.id)
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

    private var ordersListView: some View {
        CardContainer {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.orders.enumerated()), id: \.element.id) { index, order in
                    orderRow(order)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if index < viewModel.orders.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func orderRow(_ order: AdminOrderSummary) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Order #\(order.id)")
                    .font(AppFont.title(14))
                Text(order.buyerUsername)
                    .font(AppFont.caption(12))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
                Text(order.placedAt, format: .dateTime.month().day().hour().minute())
                    .font(AppFont.caption(11))
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            StatusBadge(status: order.status)
            NavigationLink("View", value: order)
                .buttonStyle(SecondaryButtonStyle())
            if order.status == .processing {
                Button("Complete") {
                    Task {
                        guard let token = session.token else { return }
                        await viewModel.complete(token: token, orderId: order.id)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                Button("Cancel") {
                    Task {
                        guard let token = session.token else { return }
                        await viewModel.cancel(token: token, orderId: order.id)
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }
}

struct AdminOrderDetailView: View {
    let orderId: Int
    @StateObject private var viewModel = AdminOrderDetailViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let order = viewModel.order {
                SectionHeader(title: "Order #\(order.id)", subtitle: "Buyer \(order.buyerUsername)")
                StatusBadge(status: order.status)

                List(order.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.description)
                                .font(AppFont.title(14))
                            Text("Wholesale \(item.unitWholesalePrice, format: .currency(code: "USD"))")
                                .font(AppFont.caption(12))
                                .foregroundColor(AppTheme.textSecondary)
                            Text("Retail \(item.unitRetailPrice, format: .currency(code: "USD"))")
                                .font(AppFont.caption(12))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text("x\(item.quantity)")
                            .font(AppFont.title(13))
                    }
                    .padding(.vertical, 4)
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

struct AdminProductDetailView: View {
    let productId: Int
    let initialProduct: AdminProduct?
    let onProductUpdated: ((AdminProduct) -> Void)?
    @StateObject private var viewModel = AdminProductDetailViewModel()
    @EnvironmentObject private var session: AppSession
    @State private var editorMode: ProductEditorMode?

    init(productId: Int, initialProduct: AdminProduct? = nil, onProductUpdated: ((AdminProduct) -> Void)? = nil) {
        self.productId = productId
        self.initialProduct = initialProduct
        self.onProductUpdated = onProductUpdated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let product = viewModel.product ?? initialProduct {
                HStack(alignment: .top) {
                    SectionHeader(title: product.description, subtitle: "Product #\(product.id)")
                    Spacer()
                    Button("Edit") {
                        editorMode = .edit(product)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Wholesale \(product.wholesalePrice, format: .currency(code: "USD"))")
                            .font(AppFont.title(14))
                        Text("Retail \(product.retailPrice, format: .currency(code: "USD"))")
                            .font(AppFont.title(14))
                        Text("Stock \(product.stockQuantity)")
                            .font(AppFont.body(13))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                EmptyStateView(title: "Product not found", message: "We could not load this product.", symbol: "exclamationmark.triangle")
            }
        }
        .padding(24)
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token, productId: productId)
        }
        .sheet(item: $editorMode) { mode in
            ProductEditorView(mode: mode) { values in
                Task {
                    guard let token = session.token else { return }
                    let request = AdminProductUpdateRequest(
                        description: values.description,
                        wholesalePrice: values.wholesalePrice,
                        retailPrice: values.retailPrice,
                        stockQuantity: values.stockQuantity
                    )
                    if let updated = await viewModel.update(token: token, productId: productId, request: request) {
                        onProductUpdated?(updated)
                    }
                }
            }
            .frame(minWidth: 420, minHeight: 360)
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

struct AdminSummaryView: View {
    @StateObject private var viewModel = AdminSummaryViewModel()
    @EnvironmentObject private var session: AppSession

    var body: some View {
        let highlightCardMinHeight: CGFloat = 96

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Sales summary", subtitle: "Profit, popularity, and totals.")

                HStack(alignment: .top, spacing: 16) {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Most profitable product")
                                .font(AppFont.title(15))
                            if let profit = viewModel.profitSummary {
                                Text(profit.description)
                                    .font(AppFont.title(14))
                                    .lineLimit(2)
                                Text(profit.totalProfit, format: .currency(code: "USD"))
                                    .font(AppFont.display(18))
                            } else {
                                Text("No completed orders yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: highlightCardMinHeight, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Total items sold")
                                .font(AppFont.title(15))
                            if let total = viewModel.totalSold {
                                Text("\(total.totalItems) items")
                                    .font(AppFont.display(18))
                            } else {
                                Text("No completed orders yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: highlightCardMinHeight, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(alignment: .top, spacing: 16) {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top 3 popular products")
                                .font(AppFont.title(15))
                            if viewModel.popularItems.isEmpty {
                                Text("No completed orders yet")
                                    .font(AppFont.caption(12))
                                    .foregroundColor(AppTheme.textSecondary)
                            } else {
                                ForEach(viewModel.popularItems.prefix(3)) { item in
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
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .frame(maxWidth: .infinity)

                    Color.clear
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(24)
        }
        .task {
            guard let token = session.token else { return }
            await viewModel.load(token: token)
        }
        .alert("Unable to load summary", isPresented: errorBinding) {
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

struct AdminProductFormValues {
    var description: String
    var wholesalePrice: Double
    var retailPrice: Double
    var stockQuantity: Int
}

enum ProductEditorMode: Identifiable {
    case create
    case edit(AdminProduct)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let product):
            return "edit-\(product.id)"
        }
    }
}

struct ProductEditorView: View {
    let mode: ProductEditorMode
    let onSave: (AdminProductFormValues) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var description: String
    @State private var wholesalePrice: Double
    @State private var retailPrice: Double
    @State private var stockQuantity: Int

    init(mode: ProductEditorMode, onSave: @escaping (AdminProductFormValues) -> Void) {
        self.mode = mode
        self.onSave = onSave
        switch mode {
        case .create:
            _description = State(initialValue: "")
            _wholesalePrice = State(initialValue: 1.0)
            _retailPrice = State(initialValue: 2.0)
            _stockQuantity = State(initialValue: 1)
        case .edit(let product):
            _description = State(initialValue: product.description)
            _wholesalePrice = State(initialValue: product.wholesalePrice)
            _retailPrice = State(initialValue: product.retailPrice)
            _stockQuantity = State(initialValue: product.stockQuantity)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: titleText, subtitle: "Update product details and pricing.")

            VStack(alignment: .leading, spacing: 10) {
                Text("Description")
                    .font(AppFont.caption(12))
                TextField("Organic Apples", text: $description)
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Wholesale")
                            .font(AppFont.caption(12))
                        TextField("", value: $wholesalePrice, format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        Text("Retail")
                            .font(AppFont.caption(12))
                        TextField("", value: $retailPrice, format: .number)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                Text("Stock quantity")
                    .font(AppFont.caption(12))
                TextField("", value: $stockQuantity, format: .number)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") { dismiss() }
                    .buttonStyle(SecondaryButtonStyle())
                Spacer()
                Button("Save") {
                    let values = AdminProductFormValues(
                        description: description,
                        wholesalePrice: wholesalePrice,
                        retailPrice: retailPrice,
                        stockQuantity: stockQuantity
                    )
                    onSave(values)
                    dismiss()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(24)
    }

    private var titleText: String {
        switch mode {
        case .create:
            return "New product"
        case .edit:
            return "Edit product"
        }
    }
}
