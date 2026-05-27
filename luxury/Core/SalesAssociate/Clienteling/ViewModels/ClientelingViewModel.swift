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
            filtered = filtered.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                (client.phone?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.email?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        return filtered
    }
    
    func loadClients() async {
        isLoading = true
        errorMessage = nil
        
        let mockClients = [
            Client(id: Client.mockRahulId, name: "Rahul Bajaj", tier: .uhnw, lastVisit: "Today", ltv: 12450000.0, initial: "RB", isHot: true, phone: "+91 98210 54321", email: "rahul.bajaj@example.com"),
            Client(id: Client.mockPriyaId, name: "Priya Shah", tier: .uhnw, lastVisit: "3 days", ltv: 8520000.0, initial: "PS", phone: "+91 98765 43210", email: "priya.shah@example.com"),
            Client(id: Client.mockDeepaId, name: "Deepa Srinivas", tier: .vip, lastVisit: "Today", ltv: 3100000.0, initial: "DS", isHot: true, phone: "+91 98123 45678", email: "deepa.srinivas@example.com"),
            Client(id: Client.mockAnanyaId, name: "Ananya Kapoor", tier: .vip, lastVisit: "1 week", ltv: 2480000.0, initial: "AK", phone: "+91 98989 89898", email: "ananya.kapoor@example.com"),
            Client(id: Client.mockVikramId, name: "Vikram Nair", tier: .vip, lastVisit: "2 weeks", ltv: 1840000.0, initial: "VN", phone: "+91 97654 32109", email: "vikram.nair@example.com"),
            Client(id: Client.mockRohitId, name: "Rohit Malhotra", tier: .standard, lastVisit: "1 month", ltv: 420000.0, initial: "RM", phone: "+91 95432 10987", email: "rohit.malhotra@example.com")
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
