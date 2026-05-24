//
//  BarcodeLookupViewModel.swift
//  luxury
//

import SwiftUI
import Observation
import Supabase

@Observable
final class BarcodeLookupViewModel {
    var isLoading = false
    var errorMessage: String?
    var scannedItem: CatalogEntity?
    var liveStockCount: Int = 0
    
    func lookupItem(by code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        scannedItem = nil
        liveStockCount = 0
        
        Task {
            do {
                // Fetch catalog item by UPC/Barcode
                let item: CatalogEntity = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .eq("bar_code", value: trimmed)
                    .single()
                    .execute()
                    .value
                
                await MainActor.run {
                    self.scannedItem = item
                    
                    let totalProductIds = item.productIds?.count ?? 0
                    let reservedCount = item.reserved?.count ?? 0
                    self.liveStockCount = max(0, totalProductIds - reservedCount)
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Item not found for barcode: \(trimmed)"
                    self.isLoading = false
                }
            }
        }
    }
}
