//
//  StockSearchViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase
import PostgREST

@Observable
final class StockSearchViewModel {
    var searchText: String = ""
    var stockItems: [StockItem] = []
    
    func fetchItems() {
        Task {
            do {
                let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                var newItems: [StockItem] = []
                for catalog in catalogs {
                    let totalCount = catalog.productIds?.count ?? 0
                    let reservedCount = catalog.reserved?.count ?? 0
                    let available = totalCount - reservedCount
                    
                    newItems.append(StockItem(
                        brand: catalog.brand,
                        name: catalog.name,
                        qty: available,
                        rfid: true, // Assuming true for now
                        alert: available < 3
                    ))
                }
                
                await MainActor.run {
                    self.stockItems = newItems
                }
            } catch {
                print("Failed to fetch stock items: \(error)")
            }
        }
    }
    
    var filteredItems: [StockItem] {
        if searchText.isEmpty {
            return stockItems
        }
        return stockItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.brand.localizedCaseInsensitiveContains(searchText) }
    }
}
