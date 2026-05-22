//
//  CatalogService.swift
//  luxury
//
//  Created by Aditya Chauhan on 21/05/26.
//

import Foundation
import Supabase

final class CatalogService {
    private let client = SupabaseManager.shared.client
    
    func fetchCatalogs() async throws -> [CatalogEntity] {
        let response: [CatalogEntity] = try await client
            .from("catalogs")
            .select()
            .execute()
            .value
        return response
    }
    
    func addCatalog(_ catalog: CatalogEntity) async throws {
        try await client
            .from("catalogs")
            .insert(catalog)
            .execute()
    }
    
    func updateCatalog(_ catalog: CatalogEntity) async throws {
        try await client
            .from("catalogs")
            .update(catalog)
            .eq("id", value: catalog.id.uuidString)
            .execute()
    }
    
    func deleteCatalog(id: UUID) async throws {
        try await client
            .from("catalogs")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    func fetchInventory() async throws -> [InventoryItem] {
        let response: [InventoryItem] = try await client
            .from("inventory")
            .select()
            .execute()
            .value
        return response
    }
    
    func fetchBoutiques() async throws -> [CorporateBoutique] {
        let response: [CorporateBoutique] = try await client
            .from("boutiques")
            .select()
            .execute()
            .value
        return response
    }
}
