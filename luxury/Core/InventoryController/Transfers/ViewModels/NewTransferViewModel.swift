//
//  NewTransferViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase
import PostgREST

@Observable
final class NewTransferViewModel {
    var sourceStore: CorporateBoutique?
    var destinationStore: CorporateBoutique?
    var availableBoutiques: [CorporateBoutique] = []
    
    var items: [TransferItem] = []
    var approvalState: ApprovalState = .waiting
    var packingSlipGenerated: Bool = false
    
    var showAlert: Bool = false
    var alertMessage: String = ""
    var alertTitle: String = ""
    
    var availableProducts: [CatalogEntity] = []
    
    var fetchBoutiquesHandler: () async throws -> [CorporateBoutique]
    var fetchProfileHandler: () async throws -> (UserRole, Any)?
    var fetchCatalogsHandler: () async throws -> [CatalogEntity]
    var fetchInventoryHandler: (UUID, UUID) async throws -> [InventoryItem]
    var updateInventoryHandler: (UUID, Int, Int) async throws -> Void
    
    init() {
        self.fetchBoutiquesHandler = {
            try await SupabaseManager.shared.client
                .from("boutiques")
                .select()
                .eq("status", value: "approved")
                .execute()
                .value
        }
        self.fetchProfileHandler = {
            try await ProfileService().fetchCurrentProfile()
        }
        self.fetchCatalogsHandler = {
            try await SupabaseManager.shared.client
                .from("catalogs")
                .select()
                .execute()
                .value
        }
        self.fetchInventoryHandler = { skuId, storeId in
            try await SupabaseManager.shared.client
                .from("inventory")
                .select()
                .eq("sku_id", value: skuId.uuidString)
                .eq("store_id", value: storeId.uuidString)
                .execute()
                .value
        }
        self.updateInventoryHandler = { id, newQty, expectedQty in
            try await SupabaseManager.shared.client
                .from("inventory")
                .update(["quantity": newQty])
                .eq("id", value: id.uuidString)
                .eq("quantity", value: expectedQty)
                .execute()
        }
    }
    
    var hasStockError: Bool {
        items.contains(where: { $0.qty > $0.availableQty })
    }
    
    func fetchBoutiques() {
        Task {
            do {
                let boutiques = try await fetchBoutiquesHandler()
                let profileTuple = try? await fetchProfileHandler()
                var storeId: UUID? = nil
                if let staff = profileTuple?.1 as? StaffModel {
                    storeId = staff.boutiqueId
                } else if let managerBoutique = profileTuple?.1 as? CorporateBoutique {
                    storeId = managerBoutique.id
                }
                
                await MainActor.run {
                    if let sId = storeId {
                        self.sourceStore = boutiques.first(where: { $0.id == sId })
                    } else {
                        self.sourceStore = boutiques.first
                    }
                    self.availableBoutiques = boutiques.filter { $0.id != self.sourceStore?.id }
                    self.destinationStore = nil
                }
            } catch {
                print("Error fetching boutiques for transfer: \(error)")
            }
        }
    }
    
    func fetchAvailableProducts() {
        Task {
            do {
                let products = try await fetchCatalogsHandler()
                await MainActor.run {
                    self.availableProducts = products
                }
            } catch {}
        }
    }
    
    func scanItem(barcode: String) async -> Result<Void, Error> {
        guard let sourceId = sourceStore?.id else {
            return .failure(NSError(domain: "Transfer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source boutique not set."]))
        }
        
        do {
            let catalogs = try await fetchCatalogsHandler()
            guard let catalogItem = catalogs.first(where: { $0.barCode.lowercased() == barcode.lowercased() || $0.catalogId.lowercased() == barcode.lowercased() }) else {
                return .failure(NSError(domain: "Transfer", code: 4, userInfo: [NSLocalizedDescriptionKey: "Invalid SKU/Barcode scanned."]))
            }
            
            if items.contains(where: { $0.sku.lowercased() == catalogItem.barCode.lowercased() }) {
                return .failure(NSError(domain: "Transfer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Duplicate Scan: \(catalogItem.name) is already in the transfer list."]))
            }
            
            let inventoryList = try await fetchInventoryHandler(catalogItem.id, sourceId)
            
            guard let firstInventory = inventoryList.first, firstInventory.quantity > 0 else {
                return .failure(NSError(domain: "Transfer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Warning: \(catalogItem.name) is not available at the source location."]))
            }
            
            await MainActor.run {
                let newItem = TransferItem(
                    sku: catalogItem.barCode,
                    name: catalogItem.name,
                    qty: 1,
                    availableQty: firstInventory.quantity
                )
                self.items.append(newItem)
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func confirmTransfer() async -> Result<Void, Error> {
        guard !items.isEmpty else {
            return .failure(NSError(domain: "Transfer", code: 5, userInfo: [NSLocalizedDescriptionKey: "Block: Cannot confirm transfer with zero items."]))
        }
        guard let sourceId = sourceStore?.id, let destId = destinationStore?.id else {
            return .failure(NSError(domain: "Transfer", code: 6, userInfo: [NSLocalizedDescriptionKey: "Source or Destination store not selected."]))
        }
        
        do {
            let boutiques = try await fetchBoutiquesHandler()
            guard boutiques.contains(where: { $0.id == destId }) else {
                return .failure(NSError(domain: "Transfer", code: 7, userInfo: [NSLocalizedDescriptionKey: "Error: Destination boutique is no longer available."]))
            }
            
            for item in items {
                let catalogs = try await fetchCatalogsHandler()
                guard let catalogItem = catalogs.first(where: { $0.barCode.lowercased() == item.sku.lowercased() }) else {
                    throw NSError(domain: "Transfer", code: 8, userInfo: [NSLocalizedDescriptionKey: "No stock record found for \(item.name)."])
                }
                
                let inventoryList = try await fetchInventoryHandler(catalogItem.id, sourceId)
                
                guard let firstInventory = inventoryList.first else {
                    throw NSError(domain: "Transfer", code: 8, userInfo: [NSLocalizedDescriptionKey: "No stock record found for \(item.name)."])
                }
                
                if firstInventory.quantity < item.qty {
                    throw NSError(domain: "Transfer", code: 9, userInfo: [NSLocalizedDescriptionKey: "Insufficient stock for \(item.name) (requested: \(item.qty), available: \(firstInventory.quantity))."])
                }
                
                try await updateInventoryHandler(firstInventory.id, firstInventory.quantity - item.qty, firstInventory.quantity)
            }
            
            let newRequest = TransferRequest(
                reference: "TR-\(Int.random(in: 1000...9999))",
                source: sourceStore?.name ?? "Source Store",
                destination: destinationStore?.name ?? "Dest Store",
                items: items,
                status: "Submitted",
                badgeStatus: .neutral
            )
            
            TransferPersistence.shared.saveTransfer(newRequest)
            
            SystemLogService.shared.logAction(
                category: .inventory,
                severity: .info,
                message: "Stock Transfer \(newRequest.reference) initiated from \(newRequest.source) to \(newRequest.destination) with \(newRequest.itemCount) items.",
                boutiqueName: sourceStore?.name
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name("StockTransferReceived"),
                object: nil,
                userInfo: [
                    "reference": newRequest.reference,
                    "source": newRequest.source,
                    "destination": newRequest.destination,
                    "destinationBoutiqueId": destId.uuidString
                ]
            )
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func incrementQty(for itemId: UUID) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if items[index].qty < items[index].availableQty {
                items[index].qty += 1
            } else {
                alertTitle = "Stock Limit Reached"
                alertMessage = "Cannot request more than the available stock (\(items[index].availableQty) units)."
                showAlert = true
            }
        }
    }
    
    func decrementQty(for itemId: UUID) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if items[index].qty > 1 {
                items[index].qty -= 1
            }
        }
    }
    
    func submit() {
        approvalState = .waiting
    }
    
    func approve() {
        approvalState = .approved
    }
    
    func completeSession() {
        packingSlipGenerated = true
    }
}
