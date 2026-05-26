import Foundation

struct PurchasedItem: Codable, Identifiable {
    let id: UUID
    var uid: UUID
    var productId: UUID
    var reservedDate: Date?
    var deliveryDate: Date?
    var transactionId: String
    var status: String
    var createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, uid
        case productId = "product_id"
        case reservedDate = "reserved_date"
        case deliveryDate = "delivery_date"
        case transactionId = "transaction_id"
        case status
        case createdAt = "created_at"
    }
}
