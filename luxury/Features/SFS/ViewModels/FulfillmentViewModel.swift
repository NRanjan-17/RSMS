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
    
    var fetchPurchasedItemsHandler: () async throws -> [PurchasedItemEntity]
    var fetchCatalogsHandler: () async throws -> [CatalogEntity]
    var fetchProfileHandler: () async throws -> (UserRole, Any)?
    var fetchBoutiqueHandler: (UUID) async throws -> CorporateBoutique?
    var fetchInventoryHandler: (UUID, UUID) async throws -> [InventoryItem]
    var fetchGlobalInventoryHandler: (UUID) async throws -> [InventoryItem]
    var updateInventoryHandler: (UUID, Int, Int) async throws -> Void
    var updatePurchasedItemHandler: (UUID, String, Date?) async throws -> Void
    
    init() {
        self.fetchPurchasedItemsHandler = {
            try await SupabaseManager.shared.client.from("purchased_items").select().execute().value
        }
        self.fetchCatalogsHandler = {
            try await SupabaseManager.shared.client.from("catalogs").select().execute().value
        }
        self.fetchProfileHandler = {
            try await ProfileService().fetchCurrentProfile()
        }
        self.fetchBoutiqueHandler = { id in
            try await ProfileService().fetchBoutique(id: id)
        }
        self.fetchInventoryHandler = { skuId, storeId in
            try await SupabaseManager.shared.client.from("inventory")
                .select()
                .eq("sku_id", value: skuId.uuidString)
                .eq("store_id", value: storeId.uuidString)
                .execute()
                .value
        }
        self.fetchGlobalInventoryHandler = { skuId in
            try await SupabaseManager.shared.client.from("inventory")
                .select()
                .eq("sku_id", value: skuId.uuidString)
                .execute()
                .value
        }
        self.updateInventoryHandler = { id, newQty, expectedQty in
            try await SupabaseManager.shared.client.from("inventory")
                .update(["quantity": newQty])
                .eq("id", value: id.uuidString)
                .eq("quantity", value: expectedQty)
                .execute()
        }
        self.updatePurchasedItemHandler = { id, status, deliveryDate in
            var payload: [String: String] = ["status": status]
            if let date = deliveryDate {
                payload["delivery_date"] = ISO8601DateFormatter().string(from: date)
            }
            try await SupabaseManager.shared.client.from("purchased_items")
                .update(payload)
                .eq("id", value: id.uuidString)
                .execute()
        }
        
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
                let itemsResponse = try await fetchPurchasedItemsHandler()
                let products = try await fetchCatalogsHandler()
                
                let profileTuple = try? await fetchProfileHandler()
                let staff = profileTuple?.1 as? StaffModel
                let boutiqueId = staff?.boutiqueId
                var boutiqueName = "Store"
                if let bId = boutiqueId, let boutique = try? await fetchBoutiqueHandler(bId) {
                    boutiqueName = boutique.name
                }
                
                var resolved: [PurchasedItemEntity] = []
                for var item in itemsResponse {
                    if let product = products.first(where: { $0.id == item.productId }) {
                        item.productName = product.name
                        item.productBrand = product.brand
                        item.productSku = product.catalogId
                        item.productImages = product.reserved?.compactMap { _ in nil }
                        
                        let firstChar = product.brand.first ?? "A"
                        let shelfNum = (abs(product.id.hashValue) % 5) + 1
                        let section = product.category == .watches ? "Vault" : "Aisle \(firstChar)"
                        item.storeLocation = "\(boutiqueName) - \(section), Shelf \(shelfNum)"
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
    
    func verifyScannedSku(orderSku: String?, scannedCode: String) -> Result<Void, Error> {
        let trimmedScanned = scannedCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let orderSku = orderSku?.trimmingCharacters(in: .whitespacesAndNewlines), !orderSku.isEmpty else {
            return .failure(NSError(domain: "Fulfillment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid order SKU"]))
        }
        if trimmedScanned.lowercased() == orderSku.lowercased() {
            return .success(())
        } else {
            return .failure(NSError(domain: "Fulfillment", code: 2, userInfo: [NSLocalizedDescriptionKey: "SKU mismatch. Expected \(orderSku), got \(trimmedScanned)"]))
        }
    }
    
    func secureItem(orderId: UUID) async -> Result<Void, Error> {
        do {
            let profileTuple = try? await fetchProfileHandler()
            guard let staff = profileTuple?.1 as? StaffModel, let storeId = staff.boutiqueId else {
                return .failure(NSError(domain: "Fulfillment", code: 3, userInfo: [NSLocalizedDescriptionKey: "Boutique association not found for user profile."]))
            }
            
            let item: PurchasedItemEntity
            if let existing = orders.first(where: { $0.id == orderId }) {
                item = existing
            } else {
                let items = try await fetchPurchasedItemsHandler()
                guard let found = items.first(where: { $0.id == orderId }) else {
                    return .failure(NSError(domain: "Fulfillment", code: 7, userInfo: [NSLocalizedDescriptionKey: "Order not found."]))
                }
                item = found
            }
            
            if item.status.lowercased() == "secured" || item.status.lowercased() == "ready to pick" {
                return .failure(NSError(domain: "Fulfillment", code: 4, userInfo: [NSLocalizedDescriptionKey: "Conflict: This item has already been secured for another order."]))
            }
            
            let inventoryList = try await fetchInventoryHandler(item.productId, storeId)
            
            guard let inventoryItem = inventoryList.first else {
                return .failure(NSError(domain: "Fulfillment", code: 5, userInfo: [NSLocalizedDescriptionKey: "Error: No inventory record found for this product in your store."]))
            }
            
            if inventoryItem.quantity <= 0 {
                return .failure(NSError(domain: "Fulfillment", code: 6, userInfo: [NSLocalizedDescriptionKey: "Conflict: The item is already reserved or out of stock at this boutique."]))
            }
            
            try await updateInventoryHandler(inventoryItem.id, inventoryItem.quantity - 1, inventoryItem.quantity)
            try await updatePurchasedItemHandler(orderId, "Secured", Date())
            
            await MainActor.run {
                if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                    self.orders[index].status = "Secured"
                    self.orders[index].deliveryDate = Date()
                }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func performFlagItemAsMissing(orderId: UUID) async -> Result<Void, Error> {
        do {
            let item: PurchasedItemEntity
            if let existing = orders.first(where: { $0.id == orderId }) {
                item = existing
            } else {
                let items = try await fetchPurchasedItemsHandler()
                guard let found = items.first(where: { $0.id == orderId }) else {
                    return .failure(NSError(domain: "Fulfillment", code: 7, userInfo: [NSLocalizedDescriptionKey: "Order not found."]))
                }
                item = found
            }
            
            if item.status.lowercased() != "pending" {
                return .failure(NSError(domain: "Fulfillment", code: 5, userInfo: [NSLocalizedDescriptionKey: "Cannot flag a non-pending item as missing."]))
            }
            
            try await updatePurchasedItemHandler(orderId, "Missing", nil)
            
            let inventoryList = try await fetchGlobalInventoryHandler(item.productId)
            let availableQtyList = inventoryList.filter { $0.quantity > 0 }
            
            var targetBoutiqueName = "No alternative stores available"
            if let nextInventory = availableQtyList.first {
                let boutique = try? await fetchBoutiqueHandler(nextInventory.storeId)
                if let bName = boutique?.name {
                    targetBoutiqueName = "Reassigned to \(bName)"
                }
            }
            
            SystemLogService.shared.logAction(
                category: .inventory,
                severity: .warning,
                message: "Order \(orderId.uuidString.prefix(8)) flagged as missing. Reassignment status: \(targetBoutiqueName)"
            )
            
            await MainActor.run {
                if let index = self.orders.firstIndex(where: { $0.id == orderId }) {
                    self.orders[index].status = "Missing"
                }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func updateStatusToSecured(orderId: UUID) async -> Bool {
        let result = await secureItem(orderId: orderId)
        switch result {
        case .success:
            return true
        case .failure(let error):
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func flagItemAsMissing(orderId: UUID) async -> Bool {
        let result = await performFlagItemAsMissing(orderId: orderId)
        switch result {
        case .success:
            return true
        case .failure(let error):
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func updateStatusToReadyToPick(orderId: UUID) async -> Bool {
        do {
            try await updatePurchasedItemHandler(orderId, "Ready to Pick", nil)
            
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
}
