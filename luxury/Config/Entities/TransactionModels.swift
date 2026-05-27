import Foundation

struct OrderEntity: Identifiable, Codable, Hashable {
    let id: UUID
    let cartId: UUID?
    let dateOfPurchase: Date?
    let transactionId: UUID?
    let rsmsUserId: UUID
    let totalPrice: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case cartId = "cart_id"
        case dateOfPurchase = "date_of_purchase"
        case transactionId = "transaction_id"
        case rsmsUserId = "rsms_user_id"
        case totalPrice = "total_price"
    }
}
