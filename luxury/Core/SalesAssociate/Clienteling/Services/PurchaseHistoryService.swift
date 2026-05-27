//
//  PurchaseHistoryService.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
//

import Foundation

final class PurchaseHistoryService {
    static let shared = PurchaseHistoryService()
    
    private init() {}
    
    private func localKey(for clientId: UUID) -> String {
        return "luxury_purchases_\(clientId.uuidString)"
    }
    
    func fetchPurchases(clientId: UUID) -> [ClientPurchase] {
        let key = localKey(for: clientId)
        
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                return try JSONDecoder().decode([ClientPurchase].self, from: data)
            } catch {
                print("Error decoding local purchases: \(error)")
            }
        }
        
        // Fallback for mock clients during demo
        var mockPurchases: [ClientPurchase] = []
        if clientId == Client.mockRahulId {
            mockPurchases = [
                ClientPurchase(name: "Patek Philippe Nautilus 5711/1A", price: 8200000.0, date: "Mar 2025"),
                ClientPurchase(name: "Bottega Veneta The Pouch", price: 220000.0, date: "Jan 2025"),
                ClientPurchase(name: "Rolex Submariner Date 126610", price: 1450000.0, date: "Nov 2024")
            ]
        } else if clientId == Client.mockPriyaId {
            mockPurchases = [
                ClientPurchase(name: "Hermès Birkin 30", price: 1850000.0, date: "Feb 2025"),
                ClientPurchase(name: "Chanel Classic Flap", price: 820000.0, date: "Dec 2024")
            ]
        } else if clientId == Client.mockDeepaId {
            mockPurchases = [
                ClientPurchase(name: "Dior Lady Dior Medium", price: 540000.0, date: "Apr 2025"),
                ClientPurchase(name: "Cartier Love Bracelet, 4 Diamonds", price: 1020000.0, date: "Feb 2025")
            ]
        } else if clientId == Client.mockAnanyaId {
            mockPurchases = [
                ClientPurchase(name: "Louis Vuitton Neverfull MM", price: 180000.0, date: "Jan 2025")
            ]
        } else if clientId == Client.mockVikramId {
            mockPurchases = [
                ClientPurchase(name: "Audemars Piguet Royal Oak", price: 3800000.0, date: "Apr 2025"),
                ClientPurchase(name: "Rolex Daytona", price: 2400000.0, date: "Sep 2024")
            ]
        } else if clientId == Client.mockRohitId {
            mockPurchases = [
                ClientPurchase(name: "Omega Speedmaster", price: 680000.0, date: "May 2025")
            ]
        }
        
        if !mockPurchases.isEmpty {
            savePurchases(mockPurchases, for: clientId)
            return mockPurchases
        }
        
        return []
    }
    
    func savePurchases(_ purchases: [ClientPurchase], for clientId: UUID) {
        let key = localKey(for: clientId)
        do {
            let data = try JSONEncoder().encode(purchases)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error encoding local purchases: \(error)")
        }
    }
    
    func addPurchase(clientId: UUID, name: String, price: Double, date: String = "") {
        var current = fetchPurchases(clientId: clientId)
        
        let displayDate: String
        if date.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            displayDate = formatter.string(from: Date())
        } else {
            displayDate = date
        }
        
        let newPurchase = ClientPurchase(name: name, price: price, date: displayDate)
        current.insert(newPurchase, at: 0) // Prepend newest purchase
        savePurchases(current, for: clientId)
    }
}
