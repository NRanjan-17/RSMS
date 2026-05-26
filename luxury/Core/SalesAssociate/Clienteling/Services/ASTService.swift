import Foundation
import Supabase

final class ASTService {
    static let shared = ASTService()
    
    private var client: SupabaseClient {
        SupabaseManager.shared.client
    }
    
    func fetchPurchasedItems(for clientId: UUID) async throws -> [PurchasedItem] {
        return try await client
            .from("purchased_items")
            .select()
            .eq("uid", value: clientId.uuidString)
            .execute()
            .value
    }
    
    func createAST(productId: UUID, clientId: UUID?, boutiqueId: UUID, warrantyStatus: String, description: String, remark: String) async throws -> AST {
        let payload: [String: AnyJSON] = [
            "product_id": .string(productId.uuidString),
            "client_id": clientId.map { .string($0.uuidString) } ?? .null,
            "boutique_id": .string(boutiqueId.uuidString),
            "status": .string("open"),
            "warranty_status": .string(warrantyStatus),
            "description": .string(description),
            "remark": .string(remark)
        ]
        
        let ast: [AST] = try await client
            .from("ast")
            .insert(payload)
            .select()
            .execute()
            .value
        
        guard let first = ast.first else {
            throw NSError(domain: "AST", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create AST"])
        }
        return first
    }
}
