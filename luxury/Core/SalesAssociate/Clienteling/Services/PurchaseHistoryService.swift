//
//  PurchaseHistoryService.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation
import Supabase

final class PurchaseHistoryService {
    static let shared = PurchaseHistoryService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    private func localKey(for clientId: UUID) -> String {
        return "luxury_purchases_\(clientId.uuidString)"
    }
    
    func fetchPurchases(clientId: UUID) -> [ClientPurchase] {
        let key = localKey(for: clientId)
        
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                return try JSONDecoder().decode([ClientPurchase].self, from: data)
            } catch {
                print("Error decoding local purchases: \(error)")
            }
        }
        
        return []
    }
    
    func savePurchases(_ purchases: [ClientPurchase], for clientId: UUID) {
        let key = localKey(for: clientId)
        do {
            let data = try JSONEncoder().encode(purchases)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding local purchases: \(error)")
        }
    }
    
    func syncPurchases(clientId: UUID) async {
        do {
            let dbItems: [PurchasedItem] = try await client
                .from("purchased_items")
                .select()
                .eq("uid", value: clientId.uuidString)
                .execute()
                .value
            
            if !dbItems.isEmpty {
                let productIds = dbItems.map { $0.productId }
                let dbCatalogs: [CatalogEntity] = try await client
                    .from("catalogs")
                    .select()
                    .in("id", value: productIds.map { $0.uuidString })
                    .execute()
                    .value
                
                let formatter = DateFormatter()
                formatter.dateFormat = "d MMM yyyy"
                
                let purchases = dbItems.compactMap { item in
                    if let cat = dbCatalogs.first(where: { $0.id == item.productId }) {
                        let itemDate = item.reservedDate ?? item.createdAt ?? Date()
                        let dateStr = formatter.string(from: itemDate)
                        return ClientPurchase(id: item.id, name: cat.name, price: cat.amount, date: dateStr)
                    }
                    return nil
                }
                savePurchases(purchases, for: clientId)
            } else {
                // Do not clear local cache if no records exist on Supabase (e.g. mock clients)
            }
        } catch {
            print("Supabase fetch purchased_items warning: \(error.localizedDescription)")
        }
    }
    
    func addPurchase(clientId: UUID, name: String, price: Double, date: String = "") {
        var current = fetchPurchases(clientId: clientId)
        
        let displayDate: String
        if date.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            displayDate = formatter.string(from: Date())
        } else {
            displayDate = date
        }
        
        let newPurchase = ClientPurchase(id: UUID(), name: name, price: price, date: displayDate)
        current.insert(newPurchase, at: 0)
        savePurchases(current, for: clientId)
        
        // Sync to Supabase in background
        Task {
            do {
                let dbCatalogs: [CatalogEntity] = try await client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                let matchingCatalog = dbCatalogs.first { cat in
                    name.lowercased().contains(cat.name.lowercased()) || cat.name.lowercased().contains(name.lowercased())
                }
                
                guard let targetCatalog = matchingCatalog ?? dbCatalogs.first else {
                    print("No catalogs available to map purchase.")
                    return
                }
                
                let piPayload: [String: AnyJSON] = [
                    "id": .string(newPurchase.id.uuidString),
                    "uid": .string(clientId.uuidString),
                    "product_id": .string(targetCatalog.id.uuidString),
                    "transaction_id": .string(UUID().uuidString),
                    "status": .string("Completed")
                ]
                
                try await client
                    .from("purchased_items")
                    .insert(piPayload)
                    .execute()
                print("Successfully synced purchase to purchased_items on Supabase.")
            } catch {
                print("Supabase purchased_items sync warning: \(error.localizedDescription)")
            }
        }
    }
}
