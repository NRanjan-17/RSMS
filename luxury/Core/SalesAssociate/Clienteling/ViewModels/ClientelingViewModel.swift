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
    
    var isLoading = false
    var errorMessage: String? = nil
    
    var stats: [ClientStat] = [
        ClientStat(value: "0", label: "Total"),
        ClientStat(value: "0", label: "UHNW"),
        ClientStat(value: "0", label: "VIP")
    ]
    
    var clients: [Client] = []
    
    private let clientService = ClientService()
    
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
    
    func loadClients() async {
        isLoading = true
        errorMessage = nil
        
        let mockClients = [
            Client(id: Client.mockRahulId, name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: "₹1,24,50,000", initial: "RB", isHot: true),
            Client(id: Client.mockPriyaId, name: "Priya Shah", tier: .uhnw, lastVisit: "3 days", ltv: "₹85,20,000", initial: "PS"),
            Client(id: Client.mockDeepaId, name: "Deepa Srinivas", tier: .vip, lastVisit: "Today", ltv: "₹31,00,000", initial: "DS", isHot: true),
            Client(id: Client.mockAnanyaId, name: "Ananya Kapoor", tier: .vip, lastVisit: "1 week", ltv: "₹24,80,000", initial: "AK"),
            Client(id: Client.mockVikramId, name: "Vikram Nair", tier: .vip, lastVisit: "2 weeks", ltv: "₹18,40,000", initial: "VN"),
            Client(id: Client.mockRohitId, name: "Rohit Malhotra", tier: .standard, lastVisit: "1 month", ltv: "₹4,20,000", initial: "RM")
        ]
        
        do {
            let entities = try await clientService.fetchClients()
            let dbClients = entities.map { Client(entity: $0) }
            
            var combined = mockClients
            for dbClient in dbClients {
                if let index = combined.firstIndex(where: { $0.id == dbClient.id }) {
                    combined[index] = dbClient
                } else {
                    combined.append(dbClient)
                }
            }
            
            await MainActor.run {
                self.clients = combined
            }
        } catch {
            print("Error fetching clients: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.clients = mockClients
            }
        }
        
        await MainActor.run {
            let totalCount = self.clients.count
            let uhnwCount = self.clients.filter { $0.tier == .uhnw }.count
            let vipCount = self.clients.filter { $0.tier == .vip }.count
            
            self.stats = [
                ClientStat(value: "\(totalCount)", label: "Total"),
                ClientStat(value: "\(uhnwCount)", label: "UHNW"),
                ClientStat(value: "\(vipCount)", label: "VIP")
            ]
            isLoading = false
        }
    }
}
