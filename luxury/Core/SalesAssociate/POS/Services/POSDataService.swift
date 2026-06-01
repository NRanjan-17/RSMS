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
    
    func createTransaction(amount: Double, purpose: String, clientId: UUID?, boutiqueId: UUID, staffId: UUID, paymentGatewayId: String?, isGift: Bool? = nil, isTax: Bool? = nil) async throws -> Transaction {
        var payload: [String: AnyJSON] = [
            "transaction_amount": .double(amount),
            "purpose": .string(purpose),
            "date_of_transaction": .string(ISO8601DateFormatter().string(from: Date())),
            "client_id": clientId.map { .string($0.uuidString) } ?? .null,
            "boutique_id": .string(boutiqueId.uuidString),
            "staff_id": .string(staffId.uuidString)
        ]
        if let pgId = paymentGatewayId {
            payload["payment_gateway_id"] = .string(pgId)
        }
        if let isGift = isGift {
            payload["is_gift"] = .bool(isGift)
        }
        if let isTax = isTax {
            payload["is_tax"] = .bool(isTax)
        }
        
        let txs: [Transaction] = try await client
            .from("transaction")
            .insert(payload)
            .select()
            .execute()
            .value
            
        guard let first = txs.first else {
            throw NSError(domain: "POS", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create transaction"])
        }
        return first
    }
    
    func checkout(cartId: UUID, transactionId: UUID, staffId: UUID, boutiqueId: UUID, total: Double, productIds: [UUID], clientId: UUID?) async throws {
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
        var itemsPayload: [[String: AnyJSON]] = []
        for productId in productIds {
            var piPayload: [String: AnyJSON] = [
                "product_id": .string(productId.uuidString),
                "transaction_id": .string(transactionId.uuidString),
                "boutique_id": .string(boutiqueId.uuidString),
                "staff_id": .string(staffId.uuidString),
                "status": .string("Pending")
            ]
            
            if let uid = clientId {
                piPayload["uid"] = .string(uid.uuidString)
                piPayload["client_id"] = .string(uid.uuidString)
            }
            itemsPayload.append(piPayload)
        }
        
        if !itemsPayload.isEmpty {
            let _: [[String: AnyJSON]] = try await client
                .from("purchased_items")
                .insert(itemsPayload)
                .select()
                .execute()
                .value
        }
        
        // 3. Update Client's products_purchased
        if let uid = clientId {
            // Fetch current client
            let clients: [StoreClient] = try await client
                .from("client")
                .select()
                .eq("id", value: uid.uuidString)
                .execute()
                .value
            
            if let currentClient = clients.first {
                var currentPurchased = currentClient.productsPurchased ?? []
                currentPurchased.append(contentsOf: productIds)
                
                let updatePayload: [String: AnyJSON] = [
                    "products_purchased": .array(currentPurchased.map { .string($0.uuidString) })
                ]
                try await client
                    .from("client")
                    .update(updatePayload)
                    .eq("id", value: uid.uuidString)
                    .execute()
            }
        }
        
        // 4. Update cart status to 'completed'
        try await client
            .from("cart")
            .update(["status": "completed"])
            .eq("id", value: cartId.uuidString)
            .execute()
    }
}
