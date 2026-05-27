//
//  InventoryModels.swift
//  luxury
//
<<<<<<< HEAD
//  Created by Codex on 22/05/26.
=======
//  Created by Nalinish Ranjan on 22/05/26.
>>>>>>> origin/SalesAssociate
//

import Foundation

<<<<<<< HEAD
struct InventoryRecord: Decodable, Equatable, Hashable {
    let id: UUID
    let storeId: UUID
    let skuId: UUID
    let quantity: Int
    let productAvailable: Bool
=======
struct InventoryItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let storeId: UUID
    let skuId: UUID
    var quantity: Int
    var productAvailable: Bool
>>>>>>> origin/SalesAssociate
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case storeId = "store_id"
        case skuId = "sku_id"
        case productAvailable = "product_available"
    }
}
<<<<<<< HEAD
=======

// Composite model for the Corporate Admin dashboard UI
struct ProductInventorySummary: Identifiable, Equatable, Hashable {
    var id: UUID { product.id }
    let product: CatalogEntity
    let totalQuantity: Int
    let locations: [LocationInventoryDetail]
    
    var alertStatus: StockAlertStatus {
        if totalQuantity == 0 {
            return .outOfStock
        } else if totalQuantity < 5 {
            return .lowStock
        }
        return .optimal
    }
}

struct LocationInventoryDetail: Identifiable, Equatable, Hashable {
    var id: UUID { storeId }
    let storeId: UUID
    let storeName: String
    let quantity: Int
    let isAvailable: Bool
}

enum StockAlertStatus: String, CaseIterable {
    case optimal = "Optimal"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
}
>>>>>>> origin/SalesAssociate
