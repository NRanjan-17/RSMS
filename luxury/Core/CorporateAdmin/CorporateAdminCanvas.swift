//
//  CorporateAdminCanvas.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI

struct CorporateAdminCanvas: View {
    @Environment(CorporateAdminAppState.self) private var caAppState
    
    @State private var analyticsRouter = Router()
    @State private var usersRouter = Router()
    @State private var catalogsRouter = Router()
    @State private var logsRouter = Router()
    @State private var userManagementViewModel = UserManagementViewModel()
    @State private var catalogsViewModel = CatalogsViewModel()
    @State private var inventoryRouter = Router()
    @State private var inventoryViewModel = GlobalInventoryViewModel()
    
    var body: some View {
        TabView(selection: Binding(
            get: { caAppState.selectedTab },
            set: { caAppState.selectedTab = $0 }
        )) {
            NavigationStack(path: $analyticsRouter.path) {
                GlobalAnalyticsView()
                    .navigationDestination(for: CARoute.self) { route in
                        destination(for: route, router: analyticsRouter)
                    }
            }
            .environment(analyticsRouter)
            .tabItem { Label("Analytics", systemImage: "globe") }
            .tag(CATab.globalAnalytics)
            
            NavigationStack(path: $usersRouter.path) {
                UserManagementView(viewModel: userManagementViewModel)
                    .navigationDestination(for: CARoute.self) { route in
                        destination(for: route, router: usersRouter)
                    }
                    .sheet(item: $usersRouter.presentedSheet) { route in
                        destination(for: route.value as! CARoute, router: usersRouter)
                    }
            }
            .environment(usersRouter)
            .tabItem { Label("Requests", systemImage: "person.badge.shield.checkmark.fill") }
            .tag(CATab.userManagement)
            
            NavigationStack(path: $catalogsRouter.path) {
                CatalogsView()
                    .navigationDestination(for: CARoute.self) { route in
                        destination(for: route, router: catalogsRouter)
                    }
            }
            .environment(catalogsRouter)
            .environment(catalogsViewModel)
            .tabItem { Label("Catalogs", systemImage: "book.pages.fill") }
            .tag(CATab.catalogs)
            
            NavigationStack(path: $logsRouter.path) {
                SystemLogsView()
                    .navigationDestination(for: CARoute.self) { route in
                        destination(for: route, router: logsRouter)
                    }
            }
            .environment(logsRouter)
            .tabItem { Label("Logs", systemImage: "list.bullet.rectangle.portrait.fill") }
            .tag(CATab.systemLogs)
            
            NavigationStack(path: $inventoryRouter.path) {
                GlobalInventoryView()
                    .navigationDestination(for: CARoute.self) { route in
                        destination(for: route, router: inventoryRouter)
                    }
            }
            .environment(inventoryRouter)
            .environment(inventoryViewModel)
            .tabItem { Label("Inventory", systemImage: "shippingbox.fill") }
            .tag(CATab.inventory)
        }
        .tint(AppColors.gold)
    }
    
    @ViewBuilder
    private func destination(for route: CARoute, router: Router) -> some View {
        switch route {
        case .globalAnalytics:
            GlobalAnalyticsView()
        case .userManagement:
            UserManagementView(viewModel: userManagementViewModel)
        case .catalogs:
            CatalogsView()
        case .productForm(let editProduct):
            ProductFormView(editProduct: editProduct)
        case .productDetail(let summary):
            CorporateProductDetailView(summary: summary)
        case .boutiqueConfig:
            BoutiqueConfigView()
        case .boutiqueConfigDetail(let boutique):
            BoutiqueConfigDetailView(boutique: boutique, onUpdate: { _ in })
        case .systemLogs:
            SystemLogsView()
        case .boutiqueRequestDetail(let boutique):
            RequestDetailSheet(
                title: boutique.name,
                subtitle: "Boutique Registration",
                details: [
                    ("Manager", boutique.managerName),
                    ("Phone", boutique.managerPhone),
                    ("Email", boutique.managerEmail),
                    ("Location", boutique.city),
                    ("Status", boutique.status.rawValue.capitalized)
                ],
                onApprove: { router.dismissModal() },
                onReject: { router.dismissModal() }
            )
        case .pendingBoutiques:
            PendingBoutiquesView(viewModel: userManagementViewModel)
        case .boutiqueDetail(let boutique):
            BoutiqueDetailView(boutique: boutique, viewModel: userManagementViewModel)
        case .inventoryDetail(let summary):
            ProductStockDetailView(summary: summary)
        }
    }
}


