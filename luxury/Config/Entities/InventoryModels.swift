//
//  InventoryModels.swift
//  luxury
//
//  Created by Codex on 22/05/26.
//

import Foundation

struct InventoryRecord: Decodable, Equatable, Hashable {
    let id: UUID
    let storeId: UUID
    let skuId: UUID
    let quantity: Int
    let productAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, quantity
        case storeId = "store_id"
        case skuId = "sku_id"
        case productAvailable = "product_available"
    }
}
