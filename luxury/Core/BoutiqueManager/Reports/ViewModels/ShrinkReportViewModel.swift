//
//  ShrinkReportViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class ShrinkReportViewModel {
    var totalShrinkValue: String = "\(CurrencyManager.shared.symbol)0"
    var accuracy: String = (1.0).formatted(.percent.precision(.fractionLength(1)))
    
    var recentWriteOffs: [RSMSVarianceItem] = []
    
    var liveInventory: [CatalogEntity] = []
    var stockDict: [UUID: Int] = [:]
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func fetchInventory() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
            }
            do {
                guard let profileTuple = try? await ProfileService().fetchCurrentProfile() else {
                    await MainActor.run { isLoading = false }
                    return
                }
                
                let bId: UUID?
                if let staff = profileTuple.1 as? StaffModel, let boutiqueId = staff.boutiqueId {
                    bId = boutiqueId
                } else if let boutique = profileTuple.1 as? CorporateBoutique {
                    bId = boutique.id
                } else if profileTuple.0 == .corporateAdmin {
                    bId = nil
                } else {
                    await MainActor.run { isLoading = false }
                    return
                }
                
                // 1. Fetch catalogs for live inventory
                let fetched: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                // 2. Fetch available stock dictionary
                let newStockDict = try await InventoryService.shared.fetchAvailableStockDictionary(forBoutique: bId)
                
                // 3. Fetch audits for this boutique to compute shrink data
                var auditsQuery = SupabaseManager.shared.client
                    .from("audits")
                    .select()
                if let boutiqueId = bId {
                    auditsQuery = auditsQuery.eq("boutique_id", value: boutiqueId)
                }
                
                let audits: [DBStoreAudit] = (try? await auditsQuery
                    .order("created_at", ascending: false)
                    .execute()
                    .value) ?? []
                
                // 4. Compute shrink metrics from audit data
                let catalogDict = Dictionary(uniqueKeysWithValues: fetched.map { ($0.id, $0) })
                
                // Total variance across all audits (negative variance = shrink)
                let totalVariance = audits.reduce(0) { $0 + $1.variance }
                
                // Estimate shrink value based on missing items and average catalog price
                let avgPrice: Double = fetched.isEmpty ? 0 : fetched.reduce(0.0) { $0 + $1.amount } / Double(fetched.count)
                let shrinkUnits = abs(min(totalVariance, 0))
                let shrinkValue = Double(shrinkUnits) * avgPrice
                
                // Average accuracy across completed audits
                let completedAudits = audits.filter { $0.status == .signedOff || $0.status == .inProgress }
                let avgAccuracy: Double
                if completedAudits.isEmpty {
                    avgAccuracy = 1.0
                } else {
                    avgAccuracy = completedAudits.reduce(0.0) { $0 + $1.accuracy } / Double(completedAudits.count) / 100.0
                }
                
                // 5. Build recent write-offs from audit discrepancies
                var writeOffs: [RSMSVarianceItem] = []
                for audit in audits {
                    guard let discrepancies = audit.discrepancies else { continue }
                    for disc in discrepancies {
                        let isMissing = (disc.type ?? "missing").lowercased() == "missing"
                        writeOffs.append(RSMSVarianceItem(
                            name: disc.name ?? "Unknown Item",
                            expected: isMissing ? 1 : 0,
                            actual: isMissing ? 0 : 1,
                            reason: disc.detail ?? "No details provided"
                        ))
                    }
                }
                // Limit to most recent 10 write-offs
                let recentItems = Array(writeOffs.prefix(10))
                
                await MainActor.run {
                    self.liveInventory = fetched
                    self.stockDict = newStockDict
                    self.totalShrinkValue = CurrencyManager.shared.format(amount: shrinkValue)
                    self.accuracy = avgAccuracy.formatted(.percent.precision(.fractionLength(1)))
                    self.recentWriteOffs = recentItems
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = String(localized: "Failed to load inventory: \(error.localizedDescription)")
                    self.isLoading = false
                    print("Error fetching inventory: \(error)")
                }
            }
        }
    }
}
