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
    var accuracy: String = "98.2%"
    
    var recentWriteOffs: [RSMSVarianceItem] = [
        RSMSVarianceItem(name: "Diamond Ring 18K Gold", expected: 5, actual: 4, reason: "Missing / Under Investigation"),
        RSMSVarianceItem(name: "Men's Wallet Brown", expected: 8, actual: 7, reason: "Damaged / Scrapped")
    ]
    
    var liveInventory: [CatalogEntity] = []
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
                
                DispatchQueue.main.async {
                    self.liveInventory = fetched
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
