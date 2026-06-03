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
    var totalShrinkValue: String = "\(CurrencyManager.shared.symbol)1,45,000"
    var accuracy: String = (0.982).formatted(.percent.precision(.fractionLength(1)))
    
    var recentWriteOffs: [RSMSVarianceItem] = [
        RSMSVarianceItem(name: "Diamond Ring 18K Gold", expected: 5, actual: 4, reason: "Missing / Under Investigation"),
        RSMSVarianceItem(name: "Men's Wallet Brown", expected: 8, actual: 7, reason: "Damaged / Scrapped")
    ]
    
    var liveInventory: [CatalogEntity] = []
    var stockDict: [UUID: Int] = [:]
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    func fetchInventory() {
        Task {
            isLoading = true
            errorMessage = nil
            do {
                let fetched: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                var newStockDict: [UUID: Int] = [:]
                if let profileTuple = try? await ProfileService().fetchCurrentProfile(),
                   let staff = profileTuple.1 as? StaffModel,
                   let bId = staff.boutiqueId {
                    newStockDict = try await InventoryService.shared.fetchAvailableStockDictionary(forBoutique: bId)
                }
                
                DispatchQueue.main.async {
                    self.liveInventory = fetched
                    self.stockDict = newStockDict
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = String(localized: "Failed to load inventory: \(error.localizedDescription)")
                    self.isLoading = false
                    print("Error fetching inventory: \(error)")
                }
            }
        }
    }
}
