//
//  PurchaseHistoryService.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation
import Supabase

struct DBPurchaseItem: Codable {
    let id: UUID
    let clientId: UUID
    let name: String
    let price: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case name
        case price
        case date
    }
}

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
            let dbItems: [DBPurchaseItem] = try await client
                .from("purchases")
                .select()
                .eq("client_id", value: clientId.uuidString)
                .execute()
                .value
            
            let purchases = dbItems.map {
                ClientPurchase(id: $0.id, name: $0.name, price: Double($0.price) ?? 0.0, date: $0.date)
            }
            savePurchases(purchases, for: clientId)
        } catch {
            print("Supabase fetch purchases warning: \(error.localizedDescription)")
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
        current.insert(newPurchase, at: 0) // Prepend newest purchase
        savePurchases(current, for: clientId)
        
        // Sync to Supabase in background
        Task {
            do {
                let dbItem = DBPurchaseItem(
                    id: newPurchase.id,
                    clientId: clientId,
                    name: newPurchase.name,
                    price: String(newPurchase.price),
                    date: newPurchase.date
                )
                try await client
                    .from("purchases")
                    .insert(dbItem)
                    .execute()
                print("Successfully synced purchase to Supabase.")
            } catch {
                print("Supabase purchase sync warning: \(error.localizedDescription)")
            }
        }
    }
}
