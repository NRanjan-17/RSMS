//
//  ProductModels.swift
//  luxury
//
//  Created by Jyotiraditya Chauhan on 21/05/26.
//

import Foundation

enum ProductCategory: String, Codable, CaseIterable, Equatable, Hashable {
    case watches = "Watches"
    case jewelry = "Jewelry"
    case bags = "Bags"
    case accessories = "Accessories"
    case apparel = "Apparel"
    case shoes = "Shoes"
    case other = "Other"
}

enum ReservationStatus: String, Codable, CaseIterable, Equatable, Hashable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
    case delivered = "Delivered"
}

enum ProductStatus: String, Codable, CaseIterable, Equatable, Hashable {
    case active = "Active"
    case paused = "Paused"
    case archived = "Archived"
}

struct ReservedItem: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let uid: UUID
    let reservedDate: Date
    let deliveryDate: Date?
    let transactionId: String
    let status: ReservationStatus
    
    enum CodingKeys: String, CodingKey {
        case id, uid, status
        case reservedDate = "reserved_date"
        case deliveryDate = "delivery_date"
        case transactionId = "transaction_id"
    }
    
    init(id: UUID = UUID(), uid: UUID, reservedDate: Date = Date(), deliveryDate: Date? = nil, transactionId: String, status: ReservationStatus = .pending) {
        self.id = id
        self.uid = uid
        self.reservedDate = reservedDate
        self.deliveryDate = deliveryDate
        self.transactionId = transactionId
        self.status = status
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
        case productId = "catalog_id"
        case availableStock = "available_stock"
        case barCode = "bar_code"
    }
    
    init(id: UUID = UUID(), productId: String, name: String, description: String, brand: String, category: String, availableStock: Int = 0, amount: Double, barCode: String, reserved: [ReservedItem]? = nil, status: String, collection: String? = nil) {
        self.id = id
        self.productId = productId
        self.name = name
        self.description = description
        self.brand = brand
        self.category = category
        self.availableStock = availableStock
        self.amount = amount
        self.barCode = barCode
        self.reserved = reserved
        self.status = status
        self.collection = collection
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        productId = try container.decode(String.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        brand = try container.decode(String.self, forKey: .brand)
        category = try container.decode(String.self, forKey: .category)
        availableStock = try container.decodeIfPresent(Int.self, forKey: .availableStock) ?? 0
        amount = try container.decode(Double.self, forKey: .amount)
        barCode = try container.decode(String.self, forKey: .barCode)
        reserved = try container.decodeIfPresent([ReservedItem].self, forKey: .reserved)
        status = try container.decode(String.self, forKey: .status)
        collection = try container.decodeIfPresent(String.self, forKey: .collection)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(productId, forKey: .productId)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(brand, forKey: .brand)
        try container.encode(category, forKey: .category)
        try container.encode(amount, forKey: .amount)
        try container.encode(barCode, forKey: .barCode)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(reserved, forKey: .reserved)
    }
}
