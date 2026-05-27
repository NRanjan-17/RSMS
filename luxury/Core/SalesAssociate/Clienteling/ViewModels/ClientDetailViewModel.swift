//
//  ClientDetailViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ClientDetailViewModel {
    static let defaultClient = Client(name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: 12450000.0, initial: "RB", isHot: true)
    
    var client: Client {
        didSet {
            refreshWishlist()
            refreshSizes()
            refreshPurchases()
        }
    }
    var selectedTab: String = "overview"
    let tabs = [("overview", "Overview"), ("history", "History"), ("wishlist", "Wishlist"), ("notes", "Notes")]
    
    var wishlistItems: [ClientWishlistItem] = []
    var sizes: ClientSizePreference = ClientSizePreference()
    var purchases: [ClientPurchase] = []
    
    var hasMockData: Bool {
        return Client.mockIds.contains(client.id)
    }
    
    var joinedDateText: String {
        if hasMockData {
            return "Maison Mumbai · Since Nov 2019"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            let dateStr = formatter.string(from: Date())
            return "Maison Mumbai · Since \(dateStr)"
        }
    }
    
    var stats: [(String, String)] {
        let countText = String(wishlistItems.count)
        let purchaseCountText = String(purchases.count)
        return [
            (CurrencyManager.shared.formatCompact(amount: client.ltv), "Lifetime Value"),
            (purchaseCountText, "Purchases"),
            (countText, "Wishlist")
        ]
    }
    
    init(client: Client = ClientDetailViewModel.defaultClient) {
        self.client = client
        refreshWishlist()
        refreshSizes()
        refreshPurchases()
    }
    
    func refreshWishlist() {
        self.wishlistItems = WishlistService.shared.fetchWishlist(clientId: client.id)
    }
    
    func refreshSizes() {
        self.sizes = SizePreferenceService.shared.fetchSizePreference(clientId: client.id)
    }
    
    func refreshPurchases() {
        self.purchases = PurchaseHistoryService.shared.fetchPurchases(clientId: client.id)
    }
    
    func saveSizes(_ newSizes: ClientSizePreference) {
        SizePreferenceService.shared.saveSizePreference(newSizes, for: client.id)
        self.sizes = newSizes
    }
    
    private func parsePrice(_ priceStr: String) -> Int {
        let cleanStr = priceStr.filter { $0.isNumber }
        return Int(cleanStr) ?? 0
    }
    
    private func formatIndianCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        if let formatted = formatter.string(from: NSNumber(value: value)) {
            return "\(CurrencyManager.shared.symbol)\(formatted)"
        }
        return "\(CurrencyManager.shared.symbol)\(value)"
    }
    
    func addClientPurchase(brand: String, name: String, price: Double) {
        let fullName = brand.isEmpty ? name : "\(brand) \(name)"
        PurchaseHistoryService.shared.addPurchase(clientId: client.id, name: fullName, price: price)
        
        let currentLtvVal = client.ltv
        let addedVal = price
        let newLtvVal = currentLtvVal + addedVal
        let newLtvStr = String(newLtvVal)
        
        UserDefaults.standard.set(newLtvStr, forKey: "luxury_ltv_\(client.id.uuidString)")
        
        let updatedClient = Client(
            id: client.id,
            name: client.name,
            tier: client.tier,
            lastVisit: "Today",
            ltv: newLtvVal,
            initial: client.initial,
            isHot: client.isHot,
            phone: client.phone,
            email: client.email,
            dob: client.dob,
            maritalStatus: client.maritalStatus,
            dateOfAnniversary: client.dateOfAnniversary
        )
        self.client = updatedClient
        
        NotificationCenter.default.post(name: NSNotification.Name("RefreshClients"), object: nil)
    }
    
    func addProductToWishlist(brand: String, name: String, price: Double) async {
        let newItem = ClientWishlistItem(brand: brand, name: name, price: price)
        await WishlistService.shared.addToWishlist(clientId: client.id, item: newItem)
        await MainActor.run {
            self.refreshWishlist()
        }
    }
    
    func removeProductFromWishlist(itemId: UUID) async {
        await WishlistService.shared.removeFromWishlist(clientId: client.id, itemId: itemId)
        await MainActor.run {
            self.refreshWishlist()
        }
    }
    
    var preferences: [String] {
        if hasMockData {
            return ["Rolex", "Patek Philippe", "AP", "Dark Leather", "Slim Watches", "Navy"]
        } else {
            return []
        }
    }
    
    // purchases is now stored and updated dynamically in the purchases array property
    
    var wishlist: [GroupedWishlistItem] {
        var groups: [String: [ClientWishlistItem]] = [:]
        var uniqueKeys: [String] = []
        
        for item in wishlistItems {
            let key = "\(item.brand.lowercased())-\(item.name.lowercased())"
            if groups[key] == nil {
                groups[key] = []
                uniqueKeys.append(key)
            }
            groups[key]?.append(item)
        }
        
        return uniqueKeys.compactMap { key in
            guard let items = groups[key], let first = items.first else { return nil }
            return GroupedWishlistItem(
                id: first.id,
                brand: first.brand,
                name: first.name,
                price: first.price,
                quantity: items.count,
                originalItems: items
            )
        }
    }
    
    var notes: [ClientNote] {
        if hasMockData {
            return [
                ClientNote(note: "Prefers unhurried appointments — always allocate 90 min minimum. Deep interest in movement mechanics.", date: "May 10", author: "Arjun Singh"),
                ClientNote(note: "Wife's birthday June 28. Currently scouting Cartier Love bracelet and Van Cleef Alhambra.", date: "Apr 22", author: "Arjun Singh")
            ]
        } else {
            return []
        }
    }
    
    var tickets: [ClientTicket] {
        if hasMockData {
            return [
                ClientTicket(title: "Watch Servicing - Rolex Daytona", status: "Active", date: "May 12", isActive: true),
                ClientTicket(title: "Jewelry Repair - Diamond Ring", status: "Completed", date: "Apr 05", isActive: false),
                ClientTicket(title: "Polishing - AP Royal Oak", status: "Active", date: "May 15", isActive: true)
            ]
        } else {
            return []
        }
    }
}

struct GroupedWishlistItem: Identifiable, Hashable {
    let id: UUID
    let brand: String
    let name: String
    let price: Double
    let quantity: Int
    let originalItems: [ClientWishlistItem]
}
