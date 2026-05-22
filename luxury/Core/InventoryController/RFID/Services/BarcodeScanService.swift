//
//  BarcodeScanService.swift
//  luxury
//
//  Created by Codex on 22/05/26.
//

import Foundation
import Supabase

enum BarcodeScanServiceError: LocalizedError {
    case barcodeNotFound
    case manualEntryNotFound
    
    var errorDescription: String? {
        switch self {
        case .barcodeNotFound:
            return "Product not found please verify barcode"
        case .manualEntryNotFound:
            return "No product matched please verify the code"
        }
    }
}

struct BarcodeScanPayload: Equatable {
    let barcode: String
    let product: CatalogEntity
}

final class BarcodeScanService {
    private let client = SupabaseManager.shared.client
    
    func scan(barcode: String) async throws -> BarcodeScanPayload {
        let trimmedBarcode = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        let product = try await fetchProduct(barcode: trimmedBarcode)
        
        return BarcodeScanPayload(
            barcode: trimmedBarcode,
            product: product
        )
    }
    
    func findByManualEntry(_ entry: String) async throws -> BarcodeScanPayload {
        let trimmedEntry = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        let product = try await fetchProduct(manualEntry: trimmedEntry)
        
        return BarcodeScanPayload(
            barcode: trimmedEntry,
            product: product
        )
    }

    private func fetchProduct(barcode: String) async throws -> CatalogEntity {
        let products: [CatalogEntity] = try await client.from("catalogs")
            .select()
            .eq("bar_code", value: barcode)
            .limit(1)
            .execute()
            .value
        
        guard let product = products.first else {
            throw BarcodeScanServiceError.barcodeNotFound
        }
        
        return product
    }
    
    private func fetchProduct(manualEntry: String) async throws -> CatalogEntity {
        if let product = try await fetchProduct(productCode: manualEntry) {
            return product
        }
        
        if let product = try await fetchProduct(named: manualEntry) {
            return product
        }
        
        throw BarcodeScanServiceError.manualEntryNotFound
    }
    
    private func fetchProduct(productCode: String) async throws -> CatalogEntity? {
        let products: [CatalogEntity] = try await client.from("catalogs")
            .select()
            .eq("catalog_id", value: productCode)
            .limit(1)
            .execute()
            .value
        
        return products.first
    }
    
    private func fetchProduct(named name: String) async throws -> CatalogEntity? {
        let products: [CatalogEntity] = try await client.from("catalogs")
            .select()
            .ilike("name", pattern: "%\(name)%")
            .limit(1)
            .execute()
            .value
        
        return products.first
    }
}
