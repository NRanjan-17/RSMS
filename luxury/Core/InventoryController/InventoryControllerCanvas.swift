//
//  InventoryControllerCanvas.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct InventoryControllerCanvas: View {
    @Environment(InventoryControllerAppState.self) private var icAppState
    
    @State private var stockRouter = Router()
    @State private var rfidRouter = Router()
    @State private var transfersRouter = Router()
    @State private var auditRouter = Router()
    @State private var sfsViewModel = FulfillmentViewModel()
    
    var body: some View {
        TabView(selection: Binding(
            get: { icAppState.selectedTab },
            set: { icAppState.selectedTab = $0 }
        )) {
            NavigationStack(path: $stockRouter.path) {
                StockView()
                    .navigationDestination(for: ICRoute.self) { route in
                        destination(for: route)
                    }
                    .fullScreenCover(item: $stockRouter.presentedFullScreen) { route in
                        destination(for: route.value as! ICRoute)
                    }
                    .sheet(item: $stockRouter.presentedSheet) { route in
                        destination(for: route.value as! ICRoute)
                    }
            }
            .environment(stockRouter)
            .environment(sfsViewModel)
            .tabItem { Label("Stock", systemImage: "box.truck") }
            .tag(ICTab.stock)
            
            NavigationStack(path: $rfidRouter.path) {
                RFIDView()
                    .navigationDestination(for: ICRoute.self) { route in
                        destination(for: route)
                    }
                    .fullScreenCover(item: $rfidRouter.presentedFullScreen) { route in
                        destination(for: route.value as! ICRoute)
                    }
                    .sheet(item: $rfidRouter.presentedSheet) { route in
                        destination(for: route.value as! ICRoute)
                    }
            }
            .environment(rfidRouter)
            .tabItem { Label("RFID", systemImage: "antenna.radiowaves.left.and.right") }
            .tag(ICTab.rfid)
            
            NavigationStack(path: $transfersRouter.path) {
                TransfersView()
                    .navigationDestination(for: ICRoute.self) { route in
                        destination(for: route)
                    }
                    .fullScreenCover(item: $transfersRouter.presentedFullScreen) { route in
                        destination(for: route.value as! ICRoute)
                    }
                    .sheet(item: $transfersRouter.presentedSheet) { route in
                        destination(for: route.value as! ICRoute)
                    }
            }
            .environment(transfersRouter)
            .tabItem { Label("Transfers", systemImage: "arrow.left.arrow.right") }
            .tag(ICTab.transfers)
            
            NavigationStack(path: $auditRouter.path) {
                AuditView()
                    .navigationDestination(for: ICRoute.self) { route in
                        destination(for: route)
                    }
                    .fullScreenCover(item: $auditRouter.presentedFullScreen) { route in
                        destination(for: route.value as! ICRoute)
                    }
                    .sheet(item: $auditRouter.presentedSheet) { route in
                        destination(for: route.value as! ICRoute)
                    }
            }
            .environment(auditRouter)
            .tabItem { Label("Audit", systemImage: "checkmark.shield") }
            .tag(ICTab.audit)
        }
        .tint(AppColors.gold)
    }
    
    @ViewBuilder
    private func destination(for route: ICRoute) -> some View {
        switch route {
        case .stockDetail(let alert):
            StockDetailView(alert: alert)
        case .stockSearch:
            StockSearchView()
        case .scanSessionDetail(let session):
            ScanSessionDetailView(session: session)
        case .activeScan:
            ActiveScanView()
        case .barcodeScan:
            BarcodeScanView()
        case .transferDetail(let transfer):
            TransferDetailView(transfer: transfer)
        case .newTransfer:
            NewTransferView()
        case .auditDetail(let audit):
            AuditDetailView(audit: audit)
        case .activeAudit:
            ActiveAuditView()
        case .serialCertificate:
            SerializationView()
        case .sfsOrders:
            FulfillmentView()
        case .sfsVerification(let order):
            SFSVerificationView(order: order)
        }
    }
}
