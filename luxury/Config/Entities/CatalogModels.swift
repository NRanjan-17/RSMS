//
//  ProductModels.swift
//  luxury
//
//  Created by Jyotiraditya Chauhan on 21/05/26.
//

import Foundation

enum CatalogCategory: String, Codable, CaseIterable, Equatable, Hashable {
    case watches = "Watches"
    case jewelry = "Jewelry"
    case bags = "Bags"
    case accessories = "Accessories"
    case apparel = "Apparel"
    case shoes = "Shoes"
    case other = "Other"
}

enum PurchaseStatus: String, Codable, CaseIterable, Equatable, Hashable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case delivered = "Delivered"
}

enum CatalogStatus: String, Codable, CaseIterable, Equatable, Hashable {
    case active = "Active"
    case paused = "Paused"
    case archived = "Archived"
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
    
    init(
        id: UUID = UUID(),
        uid: UUID,
        productId: UUID,
        reservedDate: Date = Date(),
        deliveryDate: Date? = nil,
        transactionId: String,
        status: PurchaseStatus = .pending
    ) {
        self.id = id
        self.uid = uid
        self.productId = productId
        self.reservedDate = reservedDate
        self.deliveryDate = deliveryDate
        self.transactionId = transactionId
        self.status = status
    }
}

struct CatalogEntity: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let catalogId: String
    let name: String
    let description: String
    let brand: String
    let category: CatalogCategory
    let amount: Double
    let barCode: String
    var status: CatalogStatus
    var reserved: [String]?
    var productIds: [String]?
    var productImages: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, brand, category, amount, status, reserved
        case catalogId = "catalog_id"
        case barCode = "bar_code"
        case productIds = "product_ids"
        case productImages = "product_images"
    }
}


