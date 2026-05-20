//
//  ClientelingViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ClientelingViewModel {
    var searchText: String = ""
    var selectedFilter: String = "All"
    let filters: [String] = ["All", "UHNW", "VIP", "Standard"]
    
    var stats: [ClientStat] = [
        ClientStat(value: "284", label: "Total"),
        ClientStat(value: "8", label: "UHNW"),
        ClientStat(value: "42", label: "VIP")
    ]
    
    var clients: [Client] = [
        Client(name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: "₹1,24,50,000", initial: "RB", isHot: true),
        Client(name: "Priya Shah", tier: .uhnw, lastVisit: "3 days", ltv: "₹85,20,000", initial: "PS"),
        Client(name: "Deepa Srinivas", tier: .vip, lastVisit: "Today", ltv: "₹31,00,000", initial: "DS", isHot: true),
        Client(name: "Ananya Kapoor", tier: .vip, lastVisit: "1 week", ltv: "₹24,80,000", initial: "AK"),
        Client(name: "Vikram Nair", tier: .vip, lastVisit: "2 weeks", ltv: "₹18,40,000", initial: "VN"),
        Client(name: "Rohit Malhotra", tier: .standard, lastVisit: "1 month", ltv: "₹4,20,000", initial: "RM")
    ]
    
    var filteredClients: [Client] {
        var filtered = clients
        if selectedFilter != "All" {
            filtered = filtered.filter { $0.tier.rawValue == selectedFilter }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        return filtered
    }
}
