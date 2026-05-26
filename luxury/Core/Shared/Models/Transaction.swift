import Foundation

enum TransactionPurpose: String, Codable {
    case purchase = "purchase"
    case refund = "refund"
    // Add more as needed
}

struct Transaction: Codable, Identifiable {
    let id: UUID
    var transactionAmount: Double
    var dateOfTransaction: Date?
    var purpose: TransactionPurpose
    
    enum CodingKeys: String, CodingKey {
        case id
        case transactionAmount = "transaction_amount"
        case dateOfTransaction = "date_of_transaction"
        case purpose
    }
}
