//
//  EndlessAisleServices.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import Foundation

public enum StockResult: Sendable, Codable, Hashable {
    case localInStock
    case outOfStockLocally(alternateLocation: String)
    case noStockAnywhere
}

public protocol InventoryService: Sendable {
    func checkStock(itemId: UUID) async throws -> StockResult
}

public final class MockInventoryService: InventoryService, @unchecked Sendable {
    private let mockItems: [UUID: EndlessAisle.Item]
    
    public init(mockItems: [UUID: EndlessAisle.Item]) {
        self.mockItems = mockItems
    }
    
    public func checkStock(itemId: UUID) async throws -> StockResult {
        try await Task.sleep(for: .milliseconds(500))
        guard let item = mockItems[itemId] else {
            return .localInStock
        }
        
        if item.sku == "SKU-001" {
            return .outOfStockLocally(alternateLocation: "Paris Boutique")
        } else if item.sku == "SKU-002" {
            return .noStockAnywhere
        } else {
            return .localInStock
        }
    }
}
