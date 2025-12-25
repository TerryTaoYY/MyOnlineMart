import SwiftUI

enum SidebarItem: Hashable {
    case buyerShop
    case buyerOrders
    case buyerWatchlist
    case buyerInsights
    case adminDashboard
    case adminProducts
    case adminOrders
    case adminSummary
    case settings
}

struct MainShellView: View {
    @EnvironmentObject private var session: AppSession
    @State private var selection: SidebarItem?

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .frame(minWidth: 980, minHeight: 640)
        .onAppear {
            if selection == nil {
                selection = defaultSelection
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    withAnimation {
                        selection = defaultSelection
                    }
                } label: {
                    Image(systemName: "house")
                }
                .help("Back to home")
            }
            ToolbarItem(placement: .automatic) {
                Button("Sign Out") {
                    session.signOut()
                }
            }
        }
    }

    private var sidebar: some View {
        List(selection: $selection) {
            if session.role == .buyer {
                Section("Shop") {
                    Label("Catalog", systemImage: "square.grid.2x2").tag(SidebarItem.buyerShop)
                    Label("Orders", systemImage: "tray.full").tag(SidebarItem.buyerOrders)
                    Label("Watchlist", systemImage: "heart").tag(SidebarItem.buyerWatchlist)
                    Label("Insights", systemImage: "chart.bar").tag(SidebarItem.buyerInsights)
                }
            }
            if session.role == .admin {
                Section("Admin") {
                    Label("Dashboard", systemImage: "sparkles").tag(SidebarItem.adminDashboard)
                    Label("Products", systemImage: "shippingbox").tag(SidebarItem.adminProducts)
                    Label("Orders", systemImage: "tray.full").tag(SidebarItem.adminOrders)
                    Label("Summary", systemImage: "chart.pie").tag(SidebarItem.adminSummary)
                }
            }
            Section("System") {
                Label("Settings", systemImage: "gear").tag(SidebarItem.settings)
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .buyerShop:
            BuyerShopView()
        case .buyerOrders:
            BuyerOrdersView()
        case .buyerWatchlist:
            BuyerWatchlistView()
        case .buyerInsights:
            BuyerInsightsView()
        case .adminDashboard:
            AdminDashboardView()
        case .adminProducts:
            AdminProductsView()
        case .adminOrders:
            AdminOrdersView()
        case .adminSummary:
            AdminSummaryView()
        case .settings:
            SettingsView()
        case .none:
            EmptyStateView(title: "Select a section", message: "Pick an area from the sidebar to get started.", symbol: "sidebar.left")
        }
    }

    private var defaultSelection: SidebarItem {
        switch session.role {
        case .admin:
            return .adminDashboard
        case .buyer:
            return .buyerShop
        case .none:
            return .settings
        }
    }
}
