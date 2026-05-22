//
//  ProductModels.swift
//  luxury
//

import Foundation

struct ReservedItem: Codable, Equatable, Hashable {
    let clientId: UUID
    let reservedDate: Date
    let expiryDate: Date
    let boutiqueId: UUID
    
    enum CodingKeys: String, CodingKey {
        case clientId = "client_id"
        case reservedDate = "reserved_date"
        case expiryDate = "expiry_date"
        case boutiqueId = "boutique_id"
    }
}

enum PurchaseStatus: String, Codable, CaseIterable, Equatable, Hashable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case delivered = "Delivered"
}

struct PurchasedItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let uid: UUID
    let productId: UUID
    let reservedDate: Date
    let deliveryDate: Date?
    let transactionId: String
    let status: PurchaseStatus
    
    enum CodingKeys: String, CodingKey {
        case id, uid, status
        case productId = "product_id"
        case reservedDate = "reserved_date"
        case deliveryDate = "delivery_date"
        case transactionId = "transaction_id"
    }
}

struct ProductEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let productId: String
    let name: String
    let description: String
    let brand: String
    let category: String
    var availableStock: Int
    let amount: Double
    let barCode: String
    var reserved: [ReservedItem]?
    var status: String
    var collection: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, brand, category, amount, reserved, status, collection
        case productId = "product_id"
        case availableStock = "available_stock"
        case barCode = "bar_code"
    }
}
