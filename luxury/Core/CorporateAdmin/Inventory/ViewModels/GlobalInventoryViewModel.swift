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
                summary.product.productId.localizedCaseInsensitiveContains(searchText) ||
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
                // Fetch products, boutiques, and inventory
                let productsResponse: [ProductEntity] = try await client.from("products").select().execute().value
                let inventoryResponse: [InventoryItem] = try await client.from("inventory").select().execute().value
                let boutiquesResponse: [CorporateBoutique] = try await client.from("boutiques").select().execute().value
                
                var newSummaries: [ProductInventorySummary] = []
                
                for product in productsResponse {
                    let productInventory = inventoryResponse.filter { $0.skuId == product.id }
                    
                    var locations: [LocationInventoryDetail] = []
                    var totalQty = 0
                    
                    for item in productInventory {
                        totalQty += item.quantity
                        
                        let storeName = boutiquesResponse.first(where: { $0.id == item.storeId })?.name ?? "Unknown Location"
                        
                        locations.append(LocationInventoryDetail(
                            storeId: item.storeId,
                            storeName: storeName,
                            quantity: item.quantity,
                            isAvailable: item.productAvailable
                        ))
                    }
                    
                    newSummaries.append(ProductInventorySummary(
                        product: product,
                        totalQuantity: totalQty,
                        locations: locations.sorted(by: { $0.storeName < $1.storeName })
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
