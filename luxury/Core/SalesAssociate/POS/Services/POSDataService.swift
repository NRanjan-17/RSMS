import Foundation
import Supabase

final class POSDataService {
    static let shared = POSDataService()
    
    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    func fetchCatalogs() async throws -> [CatalogItem] {
        return try await client
            .from("catalogs")
            .select()
            .execute()
            .value
    }
    
    func createCart(clientId: UUID?, boutiqueId: UUID, total: Double, productIds: [UUID]) async throws -> Cart {
        let payload: [String: AnyJSON] = [
            "client_id": clientId.map { .string($0.uuidString) } ?? .null,
            "boutique_id": .string(boutiqueId.uuidString),
            "status": .string("active"),
            "total_price": .double(total),
            "product_ids": .array(productIds.map { .string($0.uuidString) })
        ]
        
        let cart: [Cart] = try await client
            .from("cart")
            .insert(payload)
            .select()
            .execute()
            .value
        
        guard let first = cart.first else {
            throw NSError(domain: "POS", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create cart"])
        }
        return first
    }
    
    func checkout(cartId: UUID, transactionId: UUID, staffId: UUID, total: Double, productIds: [UUID], clientId: UUID?) async throws {
        // 1. Create Order
        let orderPayload: [String: AnyJSON] = [
            "cart_id": .string(cartId.uuidString),
            "transaction_id": .string(transactionId.uuidString),
            "rsms_user_id": .string(staffId.uuidString),
            "total_price": .double(total)
        ]
        
        let _: [Order] = try await client
            .from("order")
            .insert(orderPayload)
            .select()
            .execute()
            .value
        
        // 2. Create Purchased Items
        if let uid = clientId {
            for productId in productIds {
                let piPayload: [String: AnyJSON] = [
                    "uid": .string(uid.uuidString),
                    "product_id": .string(productId.uuidString),
                    "transaction_id": .string(transactionId.uuidString),
                    "status": .string("Pending")
                ]
                
                try await client
                    .from("purchased_items")
                    .insert(piPayload)
                    .execute()
            }
            
            // 3. Update Client's products_purchased
            // We append the new product ids. In Supabase we'd normally do this via an RPC
            // but for now we can fetch and update or leave it if RPC is preferred.
        }
        
        // 4. Update cart status to 'completed'
        try await client
            .from("cart")
            .update(["status": "completed"])
            .eq("id", value: cartId.uuidString)
            .execute()
    }
}
