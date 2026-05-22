//
//  PurchasedItemEntity.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation

struct PurchasedItemEntity: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    let uid: UUID
    let productId: UUID
    let reservedDate: Date
    var deliveryDate: Date?
    let transactionId: String
    var status: String
    let createdAt: Date
    
    var productName: String?
    var productBrand: String?
    var productSku: String?
    var productImages: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, uid, status
        case productId = "product_id"
        case reservedDate = "reserved_date"
        case deliveryDate = "delivery_date"
        case transactionId = "transaction_id"
        case createdAt = "created_at"
    }
}
