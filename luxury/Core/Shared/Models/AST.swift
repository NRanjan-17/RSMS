import Foundation

struct AST: Codable, Identifiable {
    let id: UUID
    var productId: UUID
    var clientId: UUID?
    var boutiqueId: UUID
    var status: String
    var warrantyStatus: String?
    var description: String?
    var remark: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case clientId = "client_id"
        case boutiqueId = "boutique_id"
        case status
        case warrantyStatus = "warranty_status"
        case description, remark
    }
}
