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
    static let defaultClient = Client(name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: "₹1,24,50,000", initial: "RB", isHot: true)
    
    var client: Client {
        didSet {
            refreshWishlist()
        }
    }
    var selectedTab: String = "overview"
    let tabs = [("overview", "Overview"), ("history", "History"), ("wishlist", "Wishlist"), ("notes", "Notes")]
    
    var wishlistItems: [ClientWishlistItem] = []
    
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
        if hasMockData {
            return [
                (client.ltv, "Lifetime Value"),
                ("28", "Purchases"),
                (countText, "Wishlist")
            ]
        } else {
            return [
                ("₹0", "Lifetime Value"),
                ("0", "Purchases"),
                (countText, "Wishlist")
            ]
        }
    }
    
    init(client: Client = ClientDetailViewModel.defaultClient) {
        self.client = client
        refreshWishlist()
    }
    
    func refreshWishlist() {
        self.wishlistItems = WishlistService.shared.fetchWishlist(clientId: client.id)
    }
    
    func addProductToWishlist(brand: String, name: String, price: String) async {
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
    
    var purchases: [ClientPurchase] {
        if hasMockData {
            return [
                ClientPurchase(name: "Patek Philippe Nautilus 5711/1A", price: "₹82,00,000", date: "Mar 2025"),
                ClientPurchase(name: "Bottega Veneta The Pouch", price: "₹2,20,000", date: "Jan 2025"),
                ClientPurchase(name: "Rolex Submariner Date 126610", price: "₹14,50,000", date: "Nov 2024")
            ]
        } else {
            return []
        }
    }
    
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
    let price: String
    let quantity: Int
    let originalItems: [ClientWishlistItem]
}
