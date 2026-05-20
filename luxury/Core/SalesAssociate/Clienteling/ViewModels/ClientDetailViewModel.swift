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
    
    var client: Client
    var selectedTab: String = "overview"
    let tabs = [("overview", "Overview"), ("history", "History"), ("wishlist", "Wishlist"), ("notes", "Notes")]
    
    var stats: [(String, String)] {
        [
            (client.ltv, "Lifetime Value"),
            ("28", "Purchases"),
            ("5", "Wishlist")
        ]
    }
    
    init(client: Client = ClientDetailViewModel.defaultClient) {
        self.client = client
    }
    
    var preferences: [String] = ["Rolex", "Patek Philippe", "AP", "Dark Leather", "Slim Watches", "Navy"]
    
    var purchases: [ClientPurchase] = [
        ClientPurchase(name: "Patek Philippe Nautilus 5711/1A", price: "₹82,00,000", date: "Mar 2025"),
        ClientPurchase(name: "Bottega Veneta The Pouch", price: "₹2,20,000", date: "Jan 2025"),
        ClientPurchase(name: "Rolex Submariner Date 126610", price: "₹14,50,000", date: "Nov 2024")
    ]
    
    var wishlist: [ClientWishlistItem] = [
        ClientWishlistItem(brand: "Audemars Piguet", name: "Royal Oak 15500ST", price: "₹42,00,000"),
        ClientWishlistItem(brand: "Hermès", name: "Kelly 28 Retourné", price: "₹12,80,000")
    ]
    
    var notes: [ClientNote] = [
        ClientNote(note: "Prefers unhurried appointments — always allocate 90 min minimum. Deep interest in movement mechanics.", date: "May 10", author: "Arjun Singh"),
        ClientNote(note: "Wife's birthday June 28. Currently scouting Cartier Love bracelet and Van Cleef Alhambra.", date: "Apr 22", author: "Arjun Singh")
    ]
    
    var tickets: [ClientTicket] = [
        ClientTicket(title: "Watch Servicing - Rolex Daytona", status: "Active", date: "May 12", isActive: true),
        ClientTicket(title: "Jewelry Repair - Diamond Ring", status: "Completed", date: "Apr 05", isActive: false),
        ClientTicket(title: "Polishing - AP Royal Oak", status: "Active", date: "May 15", isActive: true)
    ]
}
