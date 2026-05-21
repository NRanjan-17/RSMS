//
//  CatalogService.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import Foundation
import Supabase

final class CatalogService {
    private let client = SupabaseManager.shared.client
    
    func fetchProducts() async throws -> [ProductEntity] {
        let response: [ProductEntity] = try await client
            .from("products")
            .select()
            .execute()
            .value
        return response
    }
    
    func addProduct(_ product: ProductEntity) async throws {
        try await client
            .from("products")
            .insert(product)
            .execute()
    }
    
    func updateProduct(_ product: ProductEntity) async throws {
        try await client
            .from("products")
            .update(product)
            .eq("id", value: product.id.uuidString)
            .execute()
    }
    
    func deleteProduct(id: UUID) async throws {
        try await client
            .from("products")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}
