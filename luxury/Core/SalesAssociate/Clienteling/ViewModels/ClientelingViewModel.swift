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
        ClientStat(value: "0", label: "VIP"),
        ClientStat(value: "0", label: "Standard")
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
        
        do {
            let entities = try await clientService.fetchClients()
            let dbClients = entities.map { Client(entity: $0) }
            
            await MainActor.run {
                self.clients = dbClients
            }
        } catch {
            print("Error fetching clients: \(error)")
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.clients = []
            }
        }
        
        await MainActor.run {
            let totalCount = self.clients.count
            let uhnwCount = self.clients.filter { $0.tier == .uhnw }.count
            let vipCount = self.clients.filter { $0.tier == .vip }.count
            let standardCount = self.clients.filter { $0.tier == .standard }.count
            
            self.stats = [
                ClientStat(value: "\(totalCount)", label: "Total"),
                ClientStat(value: "\(uhnwCount)", label: "UHNW"),
                ClientStat(value: "\(vipCount)", label: "VIP"),
                ClientStat(value: "\(standardCount)", label: "Standard")
            ]
            isLoading = false
        }
    }
}
