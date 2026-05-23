//
//  GlobalInventoryViewModel.swift
//  luxury
//
//  Created by Nalinish Ranjan on 22/05/26.
//

import Foundation
import Observation
import PostgREST
import Supabase

@Observable
final class GlobalInventoryViewModel {
    var searchText: String = ""
    var filterStatus: StockAlertStatus? = nil
    
    var summaries: [ProductInventorySummary] = []
    
    var isLoading = false
    var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    var filteredSummaries: [ProductInventorySummary] {
        var result = summaries
        
        if let filterStatus = filterStatus {
            result = result.filter { $0.alertStatus == filterStatus }
        }
        
        if !searchText.isEmpty {
            result = result.filter { summary in
                summary.product.name.localizedCaseInsensitiveContains(searchText) ||
                summary.product.brand.localizedCaseInsensitiveContains(searchText) ||
                summary.product.catalogId.localizedCaseInsensitiveContains(searchText) ||
                summary.product.barCode.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var totalItemsCount: Int {
        summaries.reduce(0) { $0 + $1.totalQuantity }
    }
    
    var lowStockCount: Int {
        summaries.filter { $0.alertStatus == .lowStock }.count
    }
    
    var outOfStockCount: Int {
        summaries.filter { $0.alertStatus == .outOfStock }.count
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch catalogs directly as inventory is stored inside productIds array
                let catalogsResponse: [CatalogEntity] = try await client.from("catalogs").select().execute().value
                
                var newSummaries: [ProductInventorySummary] = []
                
                for catalog in catalogsResponse {
                    let totalQty = (catalog.productIds?.count ?? 0) - (catalog.reserved?.count ?? 0)
                    
                    // Since dev branch catalogs don't track location yet, assign stock to a default warehouse
                    var locations: [LocationInventoryDetail] = []
                    if totalQty > 0 {
                        locations.append(LocationInventoryDetail(
                            storeId: UUID(),
                            storeName: "Central Warehouse",
                            quantity: totalQty,
                            isAvailable: true
                        ))
                    }
                    
                    newSummaries.append(ProductInventorySummary(
                        product: catalog,
                        totalQuantity: totalQty,
                        locations: locations
                    ))
                }
                
                await MainActor.run {
                    self.summaries = newSummaries.sorted(by: { $0.product.name < $1.product.name })
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load inventory: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
