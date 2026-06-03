//
//  ActiveAuditViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class ActiveAuditViewModel {
    let audit: RSMSCycleCount
    
    var expectedItems: [AuditCountItem] = []
    var scannedItems: [ScannedAuditItem] = []
    var totalExpected: Int = 0
    var totalScanned: Int = 0
    var isLoading = false
    var errorMessage: String?
    
    var progress: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(totalScanned) / Double(totalExpected)
    }
    
    @ObservationIgnored var fetchProfileHandler: () async throws -> (UserRole, Any)?
    @ObservationIgnored var fetchCatalogsHandler: () async throws -> [CatalogEntity]
    @ObservationIgnored var fetchInventoryHandler: (UUID) async throws -> [InventoryItem]
    @ObservationIgnored var fetchBoutiquesHandler: () async throws -> [CorporateBoutique]
    
    init(audit: RSMSCycleCount) {
        self.audit = audit
        self.fetchProfileHandler = {
            try await ProfileService().fetchCurrentProfile()
        }
        self.fetchCatalogsHandler = {
            try await SupabaseManager.shared.client.from("catalogs").select().execute().value
        }
        self.fetchInventoryHandler = { storeId in
            try await SupabaseManager.shared.client.from("inventory")
                .select()
                .eq("store_id", value: storeId.uuidString)
                .execute()
                .value
        }
        self.fetchBoutiquesHandler = {
            try await SupabaseManager.shared.client.from("boutiques").select().execute().value
        }
    }
    
    func startSession() async {
        if let cached = AuditPersistence.shared.loadSession(id: audit.id), !cached.expectedItems.isEmpty {
            await MainActor.run {
                self.expectedItems = cached.expectedItems
                self.totalExpected = cached.expectedItems.reduce(0) { $0 + $1.expectedQty }
                self.totalScanned = cached.expectedItems.reduce(0) { $0 + $1.countedQty }
                self.scannedItems = cached.expectedItems.flatMap { item in
                    Array(repeating: ScannedAuditItem(name: item.name, ok: true), count: item.countedQty)
                }
            }
            return
        }
        
        await loadExpectedItems()
    }
    
    func loadExpectedItems() async {
        isLoading = true
        errorMessage = nil
        do {
            let profileTuple = try? await fetchProfileHandler()
            let staff = profileTuple?.1 as? StaffModel
            let storeId = staff?.boutiqueId ?? UUID()
            
            let _ = try await fetchBoutiquesHandler()
            
            let catalogsResponse = try await fetchCatalogsHandler()
            let inventoryResponse = try await fetchInventoryHandler(storeId)
            
            var items: [AuditCountItem] = []
            for product in catalogsResponse {
                let qty = inventoryResponse.first(where: { $0.skuId == product.id })?.quantity ?? 0
                items.append(
                    AuditCountItem(
                        productId: product.id,
                        name: product.name,
                        sku: product.catalogId,
                        barcode: product.barCode,
                        expectedQty: qty,
                        countedQty: 0,
                        isArchivedProduct: false
                    )
                )
            }
            
            if items.isEmpty {
                items = [
                    AuditCountItem(productId: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Diamond Ring 18K Gold", sku: "DR-18K", barcode: "DR-18K-001", expectedQty: 5, countedQty: 0, isArchivedProduct: false),
                    AuditCountItem(productId: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!, name: "Silk Scarf (Print A)", sku: "SS-PR-A", barcode: "SS-PR-A-002", expectedQty: 10, countedQty: 0, isArchivedProduct: false),
                    AuditCountItem(productId: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!, name: "Men's Wallet Brown", sku: "MW-BR-03", barcode: "MW-BR-03-003", expectedQty: 8, countedQty: 0, isArchivedProduct: false),
                    AuditCountItem(productId: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!, name: "Leather Tote L", sku: "LT-8820", barcode: "LT-8820-004", expectedQty: 10, countedQty: 0, isArchivedProduct: false),
                    AuditCountItem(productId: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!, name: "Slim Wallet", sku: "SW-1020", barcode: "SW-1020-005", expectedQty: 15, countedQty: 0, isArchivedProduct: false),
                    AuditCountItem(productId: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!, name: "Belt Classic Brown", sku: "BC-3301", barcode: "BC-3301-006", expectedQty: 25, countedQty: 0, isArchivedProduct: false)
                ]
            }
            
            let total = items.reduce(0) { $0 + $1.expectedQty }
            
            await MainActor.run {
                self.expectedItems = items
                self.totalExpected = total
                self.totalScanned = 0
                self.scannedItems = []
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func scanItem(barcode: String) -> Result<Void, Error> {
        let trimmed = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let index = expectedItems.firstIndex(where: { $0.barcode.lowercased() == trimmed.lowercased() }) else {
            return .failure(NSError(domain: "Audit", code: 1, userInfo: [NSLocalizedDescriptionKey: "SKU mismatch. Expected boutique product, got \(trimmed)."]))
        }
        
        expectedItems[index].countedQty += 1
        totalScanned += 1
        
        let item = expectedItems[index]
        let isOk = item.countedQty <= item.expectedQty
        scannedItems.insert(ScannedAuditItem(name: item.name, ok: isOk), at: 0)
        
        saveSessionState()
        return .success(())
    }
    
    func saveSessionState() {
        let session = AuditSession(
            id: audit.id,
            title: audit.title,
            date: audit.date,
            scope: audit.scope,
            status: "In Progress",
            badgeStatus: .warning,
            storeName: "Store",
            controllerName: "Controller",
            isSubmitted: false,
            expectedItems: expectedItems,
            varianceReport: nil
        )
        AuditPersistence.shared.saveSession(session)
    }
    
    func submitCount() async -> Result<VarianceReport, Error> {
        do {
            isLoading = true
            
            let profileTuple = try? await fetchProfileHandler()
            let staff = profileTuple?.1 as? StaffModel
            let storeId = staff?.boutiqueId ?? UUID()
            let controllerName = staff?.name ?? "Controller"
            
            let boutiques = try? await fetchBoutiquesHandler()
            let storeName = boutiques?.first(where: { $0.id == storeId })?.name ?? "Boutique"
            
            let catalogsResponse = try await fetchCatalogsHandler()
            let inventoryResponse = try await fetchInventoryHandler(storeId)
            
            var reportItems: [VarianceReportItem] = []
            
            for countItem in expectedItems {
                let latestCatalog = catalogsResponse.first(where: { $0.id == countItem.productId })
                let isArchived = latestCatalog == nil
                
                let snapshotExpected = inventoryResponse.first(where: { $0.skuId == countItem.productId })?.quantity ?? 0
                let variance = countItem.countedQty - snapshotExpected
                
                reportItems.append(
                    VarianceReportItem(
                        id: UUID(),
                        productName: countItem.name,
                        sku: countItem.sku,
                        expectedQty: snapshotExpected,
                        countedQty: countItem.countedQty,
                        variance: variance,
                        isArchivedProduct: isArchived
                    )
                )
            }
            
            let report = VarianceReport(
                id: UUID(),
                boutiqueName: storeName,
                date: Date(),
                controllerName: controllerName,
                items: reportItems
            )
            
            let session = AuditSession(
                id: audit.id,
                title: audit.title,
                date: audit.date,
                scope: audit.scope,
                status: "Submitted",
                badgeStatus: .pending,
                storeName: storeName,
                controllerName: controllerName,
                isSubmitted: true,
                expectedItems: expectedItems,
                varianceReport: report
            )
            
            AuditPersistence.shared.saveSession(session)
            
            await MainActor.run {
                self.isLoading = false
            }
            return .success(report)
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            return .failure(error)
        }
    }

    var missingItems: [String] {
        return expectedItems.filter { $0.countedQty == 0 }.map { $0.name }
    }
    
    func addScannedItems(barcodes: [String]) {
        for barcode in barcodes {
            let _ = scanItem(barcode: barcode)
        }
    }
    
    func sellItem(barcode: String) {
        let trimmed = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let index = expectedItems.firstIndex(where: { $0.barcode.lowercased() == trimmed.lowercased() }) else {
            return
        }
        
        let item = expectedItems[index]
        if item.expectedQty > 1 {
            expectedItems[index].expectedQty -= 1
            totalExpected -= 1
            if expectedItems[index].countedQty > expectedItems[index].expectedQty {
                expectedItems[index].countedQty = expectedItems[index].expectedQty
            }
        } else {
            totalExpected -= item.expectedQty
            totalScanned -= item.countedQty
            let name = item.name
            scannedItems.removeAll { $0.name == name }
            expectedItems.remove(at: index)
        }
        
        totalScanned = expectedItems.reduce(0) { $0 + $1.countedQty }
        
        // Regenerate scannedItems based on current countedQty to keep it in sync
        self.scannedItems = expectedItems.flatMap { item in
            Array(repeating: ScannedAuditItem(name: item.name, ok: item.countedQty <= item.expectedQty), count: item.countedQty)
        }
        
        saveSessionState()
    }
}
