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
    
    init() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("SFSOrderReceived"), object: nil, queue: .main) { [weak self] _ in
            self?.fetchOrders()
        }
    }
    
    var filteredOrders: [PurchasedItemEntity] {
        if selectedSegment == 0 {
            return orders.filter { $0.status.lowercased() == "pending" }
        } else {
            return orders.filter { $0.status.lowercased() == "secured" || $0.status.lowercased() == "ready to pick" }
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
    
    func updateStatusToReadyToPick(orderId: UUID) async -> Bool {
        do {
            try await client
                .from("purchased_items")
                .update(["status": "Ready to Pick"])
                .eq("id", value: orderId.uuidString)
                .execute()
            
            await MainActor.run {
                if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                    self.orders[index].status = "Ready to Pick"
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
    
    func dispatchOrder(order: PurchasedItemEntity, expectedQty: Int, deliveredQty: Int) async -> Bool {
        do {
            let profileService = ProfileService()
            var staffName = "Inventory Controller"
            var boutiqueId: UUID? = nil
            var boutiqueName = "Main Vault"
            
            if let profileTuple = try? await profileService.fetchCurrentProfile(),
               let staff = profileTuple.1 as? StaffModel {
                staffName = staff.name
                boutiqueId = staff.boutiqueId
                if let bId = boutiqueId, let boutique = try? await profileService.fetchBoutique(id: bId) {
                    boutiqueName = boutique.name
                }
            }
            
            let catalog: CatalogEntity = try await client
                .from("catalogs")
                .select()
                .eq("id", value: order.productId.uuidString)
                .single()
                .execute()
                .value
            
            var currentProductIds = catalog.productIds ?? []
            var currentReserved = catalog.reserved ?? []
            
            let toDeduct = min(deliveredQty, currentProductIds.count)
            if toDeduct > 0 {
                currentProductIds.removeLast(toDeduct)
            }
            
            let toRelease = expectedQty - deliveredQty
            let totalReservedToRemove = min(expectedQty, currentReserved.count)
            if totalReservedToRemove > 0 {
                currentReserved.removeLast(totalReservedToRemove)
            }
            
            try await client
                .from("catalogs")
                .update([
                    "product_ids": currentProductIds,
                    "reserved": currentReserved
                ])
                .eq("id", value: catalog.id.uuidString)
                .execute()
            
            if let storeId = boutiqueId {
                let inventory: [InventoryItem] = try await client
                    .from("inventory")
                    .select()
                    .eq("sku_id", value: catalog.id.uuidString)
                    .eq("store_id", value: storeId.uuidString)
                    .execute()
                    .value
                
                if let firstItem = inventory.first {
                    let newQty = max(0, firstItem.quantity - deliveredQty)
                    try await client
                        .from("inventory")
                        .update(["quantity": newQty])
                        .eq("id", value: firstItem.id.uuidString)
                        .execute()
                }
            }
            
            try await client
                .from("purchased_items")
                .update([
                    "status": "Delivered",
                    "delivery_date": ISO8601DateFormatter().string(from: Date())
                ])
                .eq("id", value: order.id.uuidString)
                .execute()
            
            let logMsg = "Order \(order.id.uuidString.prefix(8).uppercased()) Dispatched: SKU \(catalog.catalogId), Expected: \(expectedQty), Delivered: \(deliveredQty), Released: \(toRelease). Confirmed by: \(staffName)."
            SystemLogService.shared.logAction(
                category: .inventory,
                severity: .info,
                message: logMsg,
                boutiqueName: boutiqueName
            )
            
            await MainActor.run {
                if let idx = self.orders.firstIndex(where: { $0.id == order.id }) {
                    self.orders[idx].status = "Delivered"
                    self.orders[idx].deliveryDate = Date()
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
