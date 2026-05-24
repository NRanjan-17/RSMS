//
//  StockViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class StockViewModel {
    var totalItems: String = "0"
    var lowStockCount: String = "0"
    var outOfStockCount: String = "0"
    
    var sfsOrdersCount: String = "0"
    
    var alerts: [InventoryAlert] = []
    
    func fetchInventoryStats() {
        Task {
            do {
                let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                var total = 0
                var lowStock = 0
                var outOfStock = 0
                var newAlerts: [InventoryAlert] = []
                
                for catalog in catalogs {
                    let totalCount = catalog.productIds?.count ?? 0
                    let reservedCount = catalog.reserved?.count ?? 0
                    let available = totalCount - reservedCount
                    
                    total += available
                    
                    if available == 0 {
                        outOfStock += 1
                        newAlerts.append(InventoryAlert(itemName: catalog.name, sku: catalog.catalogId, currentQty: available, status: .error))
                    } else if available < 3 {
                        lowStock += 1
                        newAlerts.append(InventoryAlert(itemName: catalog.name, sku: catalog.catalogId, currentQty: available, status: .warning))
                    }
                }
                
                let finalTotal = total
                let finalLowStock = lowStock
                let finalOutOfStock = outOfStock
                let finalAlerts = Array(newAlerts.prefix(5))
                
                await MainActor.run {
                    self.totalItems = "\(finalTotal)"
                    self.lowStockCount = "\(finalLowStock)"
                    self.outOfStockCount = "\(finalOutOfStock)"
                    self.alerts = finalAlerts
                }
            } catch {
                print("Failed to fetch inventory stats: \(error)")
            }
        }
    }
    
    func fetchSFSCount() {
        Task {
            do {
                let items: [PurchasedItemEntity] = try await SupabaseManager.shared.client
                    .from("purchased_items")
                    .select()
                    .eq("status", value: "Pending")
                    .execute()
                    .value
                
                await MainActor.run {
                    self.sfsOrdersCount = "\(items.count)"
                }
            } catch {
            }
        }
    }
}
