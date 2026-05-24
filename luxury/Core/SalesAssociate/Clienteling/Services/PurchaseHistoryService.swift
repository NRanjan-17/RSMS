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
                ClientPurchase(name: "Patek Philippe Nautilus 5711/1A", price: "\(CurrencyManager.shared.symbol)82,00,000", date: "Mar 2025"),
                ClientPurchase(name: "Bottega Veneta The Pouch", price: "\(CurrencyManager.shared.symbol)2,20,000", date: "Jan 2025"),
                ClientPurchase(name: "Rolex Submariner Date 126610", price: "\(CurrencyManager.shared.symbol)14,50,000", date: "Nov 2024")
            ]
        } else if clientId == Client.mockPriyaId {
            mockPurchases = [
                ClientPurchase(name: "Hermès Birkin 30", price: "\(CurrencyManager.shared.symbol)18,50,000", date: "Feb 2025"),
                ClientPurchase(name: "Chanel Classic Flap", price: "\(CurrencyManager.shared.symbol)8,20,000", date: "Dec 2024")
            ]
        } else if clientId == Client.mockDeepaId {
            mockPurchases = [
                ClientPurchase(name: "Dior Lady Dior Medium", price: "\(CurrencyManager.shared.symbol)5,40,000", date: "Apr 2025"),
                ClientPurchase(name: "Cartier Love Bracelet, 4 Diamonds", price: "\(CurrencyManager.shared.symbol)10,20,000", date: "Feb 2025")
            ]
        } else if clientId == Client.mockAnanyaId {
            mockPurchases = [
                ClientPurchase(name: "Louis Vuitton Neverfull MM", price: "\(CurrencyManager.shared.symbol)1,80,000", date: "Jan 2025")
            ]
        } else if clientId == Client.mockVikramId {
            mockPurchases = [
                ClientPurchase(name: "Audemars Piguet Royal Oak", price: "\(CurrencyManager.shared.symbol)38,00,000", date: "Apr 2025"),
                ClientPurchase(name: "Rolex Daytona", price: "\(CurrencyManager.shared.symbol)24,00,000", date: "Sep 2024")
            ]
        } else if clientId == Client.mockRohitId {
            mockPurchases = [
                ClientPurchase(name: "Omega Speedmaster", price: "\(CurrencyManager.shared.symbol)6,80,000", date: "May 2025")
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
    
    func addPurchase(clientId: UUID, name: String, price: String, date: String = "") {
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
