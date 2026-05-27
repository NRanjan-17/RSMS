//
//  ClientEntity.swift
//  luxury
//
//  Created by Antigravity on 21/05/26.
//

import Foundation

struct ClientEntity: Identifiable, Codable, Hashable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var phone: String?
    var dob: String?
    var tier: String?
    var productsPurchased: [UUID]?
    let createdAt: Date
    var updatedAt: Date
    var maritalStatus: String?
    var dateOfAnniversary: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, dob, tier
        case productsPurchased = "products_purchased"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case maritalStatus = "marital_status"
        case dateOfAnniversary = "date_of_anniversary"
    }
}
