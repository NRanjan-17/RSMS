//
//  WishlistService.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation
import Supabase

struct DBWishlistItem: Codable {
    let id: UUID
    let clientId: UUID
    let brand: String
    let name: String
    let price: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case brand
        case name
        case price
    }
}

final class WishlistService {
    static let shared = WishlistService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    private func localKey(for clientId: UUID) -> String {
        return "luxury_wishlist_\(clientId.uuidString)"
    }
    
    private var localEncoder: JSONEncoder {
        return JSONEncoder()
    }
    
    private var localDecoder: JSONDecoder {
        return JSONDecoder()
    }
    
    func fetchWishlist(clientId: UUID) -> [ClientWishlistItem] {
        let key = localKey(for: clientId)
        
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                return try localDecoder.decode([ClientWishlistItem].self, from: data)
            } catch {
                print("Error decoding local wishlist: \(error)")
            }
        }
        
        // Fallback for mock clients during demo
        if Client.mockIds.contains(clientId) {
            let mockItems = [
                ClientWishlistItem(brand: "Audemars Piguet", name: "Royal Oak 15500ST", price: "\(CurrencyManager.shared.symbol)42,00,000"),
                ClientWishlistItem(brand: "Hermès", name: "Kelly 28 Retourné", price: "\(CurrencyManager.shared.symbol)12,80,000")
            ]
            saveLocalWishlist(mockItems, for: clientId)
            return mockItems
        }
        
        return []
    }
    
    func saveLocalWishlist(_ items: [ClientWishlistItem], for clientId: UUID) {
        let key = localKey(for: clientId)
        do {
            let data = try localEncoder.encode(items)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding local wishlist: \(error)")
        }
    }
    
    func addToWishlist(clientId: UUID, item: ClientWishlistItem) async {
        // 1. Update local storage immediately for responsive UI
        var currentItems = fetchWishlist(clientId: clientId)
        if !currentItems.contains(where: { $0.id == item.id }) {
            currentItems.append(item)
            saveLocalWishlist(currentItems, for: clientId)
        }
        
        // 2. Perform background synchronization to Supabase table "wishlist"
        do {
            let dbItem = DBWishlistItem(
                id: item.id,
                clientId: clientId,
                brand: item.brand,
                name: item.name,
                price: item.price
            )
            
            try await client
                .from("wishlist")
                .insert(dbItem)
                .execute()
                
            print("Successfully synced wishlist item to Supabase.")
        } catch {
            // Log warning but do not fail locally (allows RLS/connectivity issues in demo)
            print("Supabase sync warning: \(error.localizedDescription)")
        }
    }
    
    func removeFromWishlist(clientId: UUID, itemId: UUID) async {
        // 1. Update local storage immediately for responsive UI
        var currentItems = fetchWishlist(clientId: clientId)
        currentItems.removeAll { $0.id == itemId }
        saveLocalWishlist(currentItems, for: clientId)
        
        // 2. Perform background synchronization to Supabase table "wishlist"
        do {
            try await client
                .from("wishlist")
                .delete()
                .eq("id", value: itemId)
                .execute()
                
            print("Successfully deleted wishlist item from Supabase.")
        } catch {
            // Log warning but do not fail locally (allows RLS/connectivity issues in demo)
            print("Supabase delete warning: \(error.localizedDescription)")
        }
    }
}
