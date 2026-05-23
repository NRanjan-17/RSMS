//
//  FulfillmentViewModel.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class FulfillmentViewModel {
    var orders: [PurchasedItemEntity] = []
    var isLoading = false
    var errorMessage: String?
    var selectedSegment = 0
    
    private let client = SupabaseManager.shared.client
    
    var filteredOrders: [PurchasedItemEntity] {
        if selectedSegment == 0 {
            return orders.filter { $0.status.lowercased() == "pending" }
        } else {
            return orders.filter { $0.status.lowercased() == "secured" }
        }
    }
    
    func fetchOrders() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let itemsResponse: [PurchasedItemEntity] = try await client
                    .from("purchased_items")
                    .select()
                    .execute()
                    .value
                
                let products: [CatalogEntity] = try await client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                var resolved: [PurchasedItemEntity] = []
                for var item in itemsResponse {
                    if let product = products.first(where: { $0.id == item.productId }) {
                        item.productName = product.name
                        item.productBrand = product.brand
                        item.productSku = product.catalogId
                        item.productImages = product.reserved?.compactMap { _ in nil }
                    }
                    resolved.append(item)
                }
                
                await MainActor.run {
                    self.orders = resolved.sorted(by: { $0.reservedDate > $1.reservedDate })
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateStatusToSecured(orderId: UUID) async -> Bool {
        do {
            try await client
                .from("purchased_items")
                .update(["status": "Secured", "delivery_date": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: orderId.uuidString)
                .execute()
            
            await MainActor.run {
                if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                    self.orders[index].status = "Secured"
                    self.orders[index].deliveryDate = Date()
                }
            }
            return true
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
}
