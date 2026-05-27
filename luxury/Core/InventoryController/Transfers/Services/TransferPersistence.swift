//
//  TransferPersistence.swift
//  luxury
//
//  Created by Antigravity on 27/05/26.
//

import Foundation

final class TransferPersistence {
    static let shared = TransferPersistence()
    
    private let key = "rsms_stock_transfers"
    
    private init() {}
    
    func loadTransfers() -> [TransferRequest] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return [
                TransferRequest(
                    reference: "TR-9042",
                    source: "Main Boutique",
                    destination: "Airport Lounge",
                    items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 5),
                    status: "Approved",
                    badgeStatus: .success
                ),
                TransferRequest(
                    reference: "TR-9045",
                    source: "DC South",
                    destination: "Main Boutique",
                    items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 12),
                    status: "In Transit",
                    badgeStatus: .pending
                ),
                TransferRequest(
                    reference: "TR-9048",
                    source: "Main Boutique",
                    destination: "Repair Center",
                    items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 2),
                    status: "Submitted",
                    badgeStatus: .neutral
                )
            ]
        }
        
        do {
            return try JSONDecoder().decode([TransferRequest].self, from: data)
        } catch {
            return []
        }
    }
    
    func saveTransfer(_ transfer: TransferRequest) {
        var current = loadTransfers()
        current.insert(transfer, at: 0)
        saveAll(current)
    }
    
    func saveAll(_ list: [TransferRequest]) {
        do {
            let data = try JSONEncoder().encode(list)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding transfer requests: \(error)")
        }
    }
}
