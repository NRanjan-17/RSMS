//
//  ActiveAuditViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase
import UIKit

@Observable
final class ActiveAuditViewModel {
    let audit: RSMSCycleCount
    
    var yetToScanItems: [YetToScanItem] = []
    var scannedUnitIds: [UUID] = []
    var scannedItems: [ScannedAuditItem] = []
    var newlyAddedItems: [ScannedAuditItem] = []
    var unexpectedScannedItems: [UnexpectedScannedItem] = []
    var totalExpected: Int = 0
    var totalScanned: Int = 0
    var isLoading = false
    var errorMessage: String?
    
    var progress: Double {
        guard totalExpected > 0 else { return 0 }
        return Double(totalScanned) / Double(totalExpected)
    }
    
    @ObservationIgnored var fetchProfileHandler: () async throws -> (UserRole, Any)?
    @ObservationIgnored var fetchBoutiquesHandler: () async throws -> [CorporateBoutique]
    
    init(audit: RSMSCycleCount) {
        self.audit = audit
        self.fetchProfileHandler = {
            try await ProfileService().fetchCurrentProfile()
        }
        self.fetchBoutiquesHandler = {
            try await SupabaseManager.shared.client.from("boutiques").select().execute().value
        }
    }
    
    func startSession() async {
        if let cached = AuditPersistence.shared.loadSession(id: audit.id) {
            await MainActor.run {
                self.yetToScanItems = cached.yetToScanItems
                self.scannedUnitIds = cached.scannedUnitIds
                self.totalExpected = cached.yetToScanItems.count + cached.scannedUnitIds.count
                self.unexpectedScannedItems = cached.unexpectedScannedItems ?? []
                self.totalScanned = cached.scannedUnitIds.count + self.unexpectedScannedItems.count
                
                var list: [ScannedAuditItem] = []
                for item in self.unexpectedScannedItems {
                    list.append(ScannedAuditItem(name: item.barcode, ok: false))
                }
                self.newlyAddedItems = list
                self.scannedItems = []
            }
            return
        }
        
        await loadExpectedItems()
    }
    
    func loadExpectedItems() async {
        isLoading = true
        errorMessage = nil
        
        await MainActor.run {
            self.yetToScanItems.removeAll()
            self.scannedUnitIds.removeAll()
            self.scannedItems.removeAll()
            self.newlyAddedItems.removeAll()
            self.unexpectedScannedItems.removeAll()
        }
        
        do {
            let profileTuple = try? await fetchProfileHandler()
            let staff = profileTuple?.1 as? StaffModel
            let storeId = staff?.boutiqueId ?? UUID()
            
            let response: [YetToScanNetworkResponse] = try await SupabaseManager.shared.client
                .from("inventory_units")
                .select("id, serial_number, catalog_id, catalogs(name, brand)")
                .eq("boutique_id", value: storeId.uuidString)
                .eq("status", value: "Available")
                .execute()
                .value
            
            let items: [YetToScanItem] = response.map { res in
                YetToScanItem(
                    id: res.id,
                    serialNumber: res.serial_number,
                    catalogId: res.catalog_id,
                    name: res.catalogs?.name ?? "Unknown",
                    brand: res.catalogs?.brand ?? "Unknown"
                )
            }
            
            await MainActor.run {
                AuditPersistence.shared.clearSession(id: self.audit.id)
                self.yetToScanItems = items
                self.totalExpected = items.count
                self.totalScanned = 0
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func scanItem(barcode: String) async -> Result<Void, Error> {
        let cleanedToken = barcode.components(separatedBy: .whitespacesAndNewlines).joined().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if scannedItems.contains(where: { $0.name.components(separatedBy: .whitespacesAndNewlines).joined().localizedCaseInsensitiveCompare(cleanedToken) == .orderedSame }) ||
           unexpectedScannedItems.contains(where: { $0.barcode.components(separatedBy: .whitespacesAndNewlines).joined().localizedCaseInsensitiveCompare(cleanedToken) == .orderedSame }) {
            return .success(())
        }
        
        guard let index = yetToScanItems.firstIndex(where: { $0.serialNumber.components(separatedBy: .whitespacesAndNewlines).joined().localizedCaseInsensitiveCompare(cleanedToken) == .orderedSame }) else {
            do {
                let catalogsResponse: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .eq("bar_code", value: cleanedToken)
                    .execute()
                    .value
                
                if let catalog = catalogsResponse.first {
                    let unexpectedItem = UnexpectedScannedItem(id: UUID(), barcode: cleanedToken, status: "new_item")
                    unexpectedScannedItems.append(unexpectedItem)
                    newlyAddedItems.insert(ScannedAuditItem(name: catalog.name, ok: false), at: 0)
                } else {
                    let unexpectedItem = UnexpectedScannedItem(id: UUID(), barcode: cleanedToken, status: "new_item")
                    unexpectedScannedItems.append(unexpectedItem)
                    newlyAddedItems.insert(ScannedAuditItem(name: cleanedToken, ok: false), at: 0)
                }
            } catch {
                let unexpectedItem = UnexpectedScannedItem(id: UUID(), barcode: cleanedToken, status: "new_item")
                unexpectedScannedItems.append(unexpectedItem)
                newlyAddedItems.insert(ScannedAuditItem(name: cleanedToken, ok: false), at: 0)
            }
            
            totalScanned += 1
            
            #if os(iOS)
            await MainActor.run {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
            #endif
            
            saveSessionState()
            return .success(())
        }
        
        let matchedItem = yetToScanItems.remove(at: index)
        scannedUnitIds.append(matchedItem.id)
        totalScanned += 1
        
        scannedItems.insert(ScannedAuditItem(name: matchedItem.serialNumber, ok: true), at: 0)
        
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
            yetToScanItems: yetToScanItems,
            scannedUnitIds: scannedUnitIds,
            varianceReport: nil,
            unexpectedScannedItems: unexpectedScannedItems
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
            
            var reportItems: [VarianceReportItem] = []
            var discrepancies: [DiscrepancyItem] = []
            
            for missing in yetToScanItems {
                discrepancies.append(
                    DiscrepancyItem(
                        name: missing.name,
                        detail: "Serial: \(missing.serialNumber)",
                        type: "missing"
                    )
                )
            }
            
            for unexpected in unexpectedScannedItems {
                discrepancies.append(
                    DiscrepancyItem(
                        name: "Unexpected Scan",
                        detail: "Barcode: \(unexpected.barcode)",
                        type: "new"
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
            
            struct SubmitAuditPayload: Codable {
                let status: String
                let total_expected: Int
                let total_scanned: Int
                let variance: Int
                let accuracy: Double
                let discrepancies: [DiscrepancyItem]
                let scanned_unit_ids: [UUID]
            }
            
            let variance = yetToScanItems.count + unexpectedScannedItems.count
            let payload = SubmitAuditPayload(
                status: "in_progress",
                total_expected: totalExpected,
                total_scanned: totalScanned,
                variance: variance,
                accuracy: totalExpected > 0 ? (max(0.0, Double(totalExpected - variance) / Double(totalExpected)) * 100.0) : 100.0,
                discrepancies: discrepancies,
                scanned_unit_ids: scannedUnitIds
            )
            
            try await SupabaseManager.shared.client.from("audits")
                .update(payload)
                .eq("id", value: audit.id.uuidString)
                .execute()
            
            let session = AuditSession(
                id: audit.id,
                title: audit.title,
                date: audit.date,
                scope: audit.scope,
                status: "Submitted",
                badgeStatus: .success,
                storeName: storeName,
                controllerName: controllerName,
                isSubmitted: true,
                yetToScanItems: yetToScanItems,
                scannedUnitIds: scannedUnitIds,
                varianceReport: report,
                unexpectedScannedItems: unexpectedScannedItems
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
        return yetToScanItems.map { $0.serialNumber }
    }
    
    func addScannedItems(barcodes: [String]) async {
        for barcode in barcodes {
            let _ = await scanItem(barcode: barcode)
        }
    }
}
