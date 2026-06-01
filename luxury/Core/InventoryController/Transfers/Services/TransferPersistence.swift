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
        if let data = UserDefaults.standard.data(forKey: key),
           let list = try? JSONDecoder().decode([TransferRequest].self, from: data) {
            let hasDummies = list.contains(where: {
                $0.items.contains(where: { $0.name.lowercased().contains("dummy") || $0.sku.lowercased().contains("dummy") })
            })
            if !hasDummies {
                return list
            }
        }
        
        let initialList = [
            TransferRequest(
                reference: "TR-9042",
                source: "Main Boutique",
                destination: "Airport Lounge",
                items: [
                    TransferItem(sku: "W-SUB-01", name: "Rolex Submariner Date", qty: 2, availableQty: 10),
                    TransferItem(sku: "W-RO-02", name: "Audemars Piguet Royal Oak", qty: 1, availableQty: 3),
                    TransferItem(sku: "B-CF-03", name: "Chanel Classic Flap Bag", qty: 2, availableQty: 8)
                ],
                status: "Approved",
                badgeStatus: .success
            ),
            TransferRequest(
                reference: "TR-9045",
                source: "DC South",
                destination: "Main Boutique",
                items: [
                    TransferItem(sku: "B-SP-04", name: "Louis Vuitton Speedy 30", qty: 5, availableQty: 12),
                    TransferItem(sku: "W-SUB-01", name: "Rolex Submariner Date", qty: 3, availableQty: 10),
                    TransferItem(sku: "W-DAY-05", name: "Rolex Cosmograph Daytona", qty: 4, availableQty: 5)
                ],
                status: "In Transit",
                badgeStatus: .pending
            ),
            TransferRequest(
                reference: "TR-9048",
                source: "Main Boutique",
                destination: "Repair Center",
                items: [
                    TransferItem(sku: "W-SUB-01", name: "Rolex Submariner Date", qty: 1, availableQty: 10),
                    TransferItem(sku: "B-CF-03", name: "Chanel Classic Flap Bag", qty: 1, availableQty: 8)
                ],
                status: "Submitted",
                badgeStatus: .neutral
            )
        ]
        
        saveAll(initialList)
        return initialList
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
