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
    var approvalState: MockApprovalState = .waiting
    var packingSlipGenerated: Bool = false
    
    var hasStockError: Bool {
        items.contains(where: { $0.qty > $0.availableQty })
    }
    
    func fetchBoutiques() {
        Task {
            do {
                let boutiques: [CorporateBoutique] = try await SupabaseManager.shared.client
                    .from("boutiques")
                    .select()
                    .eq("status", value: "approved")
                    .execute()
                    .value
                
                await MainActor.run {
                    self.availableBoutiques = boutiques
                    if !boutiques.isEmpty {
                        self.sourceStore = boutiques.first
                        self.destinationStore = nil
                    }
                }
            } catch {
                print("Error fetching boutiques for transfer: \(error)")
            }
        }
    }
    
    func addItem(_ catalogItem: CatalogEntity) {
        // Prevent duplicate entries
        if items.contains(where: { $0.sku == catalogItem.barCode }) { return }
        
        let stock = max(0, (catalogItem.productIds?.count ?? 0) - (catalogItem.reserved?.count ?? 0))
        
        let newItem = TransferItem(
            sku: catalogItem.barCode,
            name: catalogItem.name,
            qty: 1, // Default to 1
            availableQty: stock
        )
        
        if newItem.qty <= newItem.availableQty {
            items.append(newItem)
        }
    }
    
    func incrementQty(for itemId: UUID) {
        if let index = items.firstIndex(where: { $0.id == itemId }) {
            if items[index].qty < items[index].availableQty {
                items[index].qty += 1
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
