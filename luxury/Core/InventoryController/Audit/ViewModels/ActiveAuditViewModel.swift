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
    
    var fetchProfileHandler: () async throws -> (UserRole, Any)?
    var fetchCatalogsHandler: () async throws -> [CatalogEntity]
    var fetchInventoryHandler: (UUID) async throws -> [InventoryItem]
    var fetchBoutiquesHandler: () async throws -> [CorporateBoutique]
    
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
        if let cached = AuditPersistence.shared.loadSession(id: audit.id) {
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
            
            let boutiques = try await fetchBoutiquesHandler()
            
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
                status: "Signed Off",
                badgeStatus: .success,
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
    }
