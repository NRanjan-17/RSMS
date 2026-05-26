//
//  ClientDetailViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class ClientDetailViewModel {
    static let defaultClient = Client(name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: "\(CurrencyManager.shared.symbol)1,24,50,000", initial: "RB", isHot: true)
    
    var client: Client {
        didSet {
            refreshAll()
            syncAll()
        }
    }
    
    var selectedTab: String = "overview"
    let tabs = [("overview", "Overview"), ("history", "History"), ("wishlist", "Wishlist"), ("notes", "Notes")]
    
    var wishlistItems: [ClientWishlistItem] = []
    var sizes: ClientSizePreference = ClientSizePreference()
    var purchases: [ClientPurchase] = []
    var notes: [ClientNote] = []
    var tickets: [ClientTicket] = []
    
    var joinedDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let dateStr = formatter.string(from: Date())
        return "Maison Mumbai · Since \(dateStr)"
    }
    
    var stats: [(String, String)] {
        let countText = String(wishlistItems.count)
        let purchaseCountText = String(purchases.count)
        return [
            (client.ltv, "Lifetime Value"),
            (purchaseCountText, "Purchases"),
            (countText, "Wishlist")
        ]
    }
    
    init(client: Client = ClientDetailViewModel.defaultClient) {
        self.client = client
        refreshAll()
        syncAll()
    }
    
    func refreshAll() {
        refreshWishlist()
        refreshSizes()
        refreshPurchases()
        refreshNotes()
        refreshTickets()
    }
    
    func syncAll() {
        let clientId = client.id
        Task {
            await WishlistService.shared.syncWishlist(clientId: clientId)
            await MainActor.run { refreshWishlist() }
        }
        Task {
            await PurchaseHistoryService.shared.syncPurchases(clientId: clientId)
            await MainActor.run { refreshPurchases() }
        }
        Task {
            await SizePreferenceService.shared.syncSizePreference(clientId: clientId)
            await MainActor.run { refreshSizes() }
        }
        Task {
            await NotesService.shared.syncNotes(clientId: clientId)
            await MainActor.run { refreshNotes() }
        }
        Task {
            await TicketsService.shared.syncTickets(clientId: clientId)
            await MainActor.run { refreshTickets() }
        }
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
    
    func refreshNotes() {
        self.notes = NotesService.shared.fetchNotes(clientId: client.id)
    }
    
    func refreshTickets() {
        self.tickets = TicketsService.shared.fetchTickets(clientId: client.id)
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
    
    func addClientPurchase(brand: String, name: String, price: String) {
        let fullName = brand.isEmpty ? name : "\(brand) \(name)"
        PurchaseHistoryService.shared.addPurchase(clientId: client.id, name: fullName, price: price)
        
        let currentLtvVal = parsePrice(client.ltv)
        let addedVal = parsePrice(price)
        let newLtvVal = currentLtvVal + addedVal
        let newLtvStr = formatIndianCurrency(newLtvVal)
        
        UserDefaults.standard.set(newLtvStr, forKey: "luxury_ltv_\(client.id.uuidString)")
        
        let updatedClient = Client(
            id: client.id,
            name: client.name,
            tier: client.tier,
            lastVisit: "Today",
            ltv: newLtvStr,
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
    
    func addNote(_ noteText: String) async {
        await NotesService.shared.addNote(clientId: client.id, noteText: noteText)
        await MainActor.run {
            self.refreshNotes()
        }
    }
    
    func deleteNote(noteId: UUID) async {
        await NotesService.shared.deleteNote(clientId: client.id, noteId: noteId)
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.refreshNotes()
            }
        }
    }
    
    var preferences: [String] {
        return []
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
}

struct GroupedWishlistItem: Identifiable, Hashable {
    let id: UUID
    let brand: String
    let name: String
    let price: String
    let quantity: Int
    let originalItems: [ClientWishlistItem]
}
