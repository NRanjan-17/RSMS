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
        case productId = "product_id"
        case availableStock = "available_stock"
        case barCode = "bar_code"
    }
}
