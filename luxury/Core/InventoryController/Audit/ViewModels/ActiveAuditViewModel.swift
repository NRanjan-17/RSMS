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
        
        let currentTotalScanned = self.totalScanned
        let currentTotalExpected = self.totalExpected
        let auditId = self.audit.id
        
        Task {
            struct ProgressUpdate: Codable {
                let status: String
                let total_expected: Int
                let total_scanned: Int
            }
            let payload = ProgressUpdate(status: "in_progress", total_expected: currentTotalExpected, total_scanned: currentTotalScanned)
            do {
                try await SupabaseManager.shared.client.from("audits")
                    .update(payload)
                    .eq("id", value: auditId)
                    .execute()
            } catch {
                print("Failed to sync audit progress to DB: \(error)")
            }
        }
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
            
            // Push update to Supabase audits table
            let totalVar = reportItems.reduce(0) { $0 + abs($1.variance) }
            let totalScanned = reportItems.reduce(0) { $0 + $1.countedQty }
            let totalExp = reportItems.reduce(0) { $0 + $1.expectedQty }
            let acc = totalExp > 0 ? max(0, min(100, (1.0 - Double(totalVar)/Double(totalExp)) * 100.0)) : 100.0
            
            struct DiscrepancyItem: Codable {
                let name: String
                let detail: String
                let type: String
            }
            
            var discrepancies: [DiscrepancyItem] = []
            for item in reportItems where item.variance != 0 {
                if item.variance < 0 {
                    discrepancies.append(DiscrepancyItem(name: item.productName, detail: "Missing \(abs(item.variance)) units", type: "missing"))
                } else {
                    discrepancies.append(DiscrepancyItem(name: item.productName, detail: "Found \(item.variance) extra units", type: "new"))
                }
            }
            
            struct AuditUpdate: Codable {
                let status: String
                let total_expected: Int
                let total_scanned: Int
                let variance: Int
                let accuracy: Double
                let discrepancies: [DiscrepancyItem]
                let signed_off_by: UUID
                let signed_off_at: String
            }
            
            let updatePayload = AuditUpdate(
                status: "signed_off",
                total_expected: totalExp,
                total_scanned: totalScanned,
                variance: totalVar,
                accuracy: acc,
                discrepancies: discrepancies,
                signed_off_by: staff?.authUserId ?? UUID(),
                signed_off_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await SupabaseManager.shared.client.from("audits")
                .update(updatePayload)
                .eq("id", value: audit.id)
                .execute()
            
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
