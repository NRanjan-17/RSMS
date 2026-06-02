//
//  ClientelingViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase
import PostgREST

@Observable
final class ClientelingViewModel {
    var searchText: String = ""
    var selectedFilter: String = "All"
    let filters: [String] = ["All", "High Networth", "VIP", "Standard"]
    
    var isLoading = false
    var errorMessage: String? = nil
    
    var stats: [ClientStat] = [
        ClientStat(value: "0", label: "Total"),
        ClientStat(value: "0", label: "High Networth"),
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
        return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    func loadClients() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let entities = try await clientService.fetchClients()
            var dbClients = entities.map { Client(entity: $0) }
            
            // Fetch upcoming appointments to determine isHot
            do {
                struct ClientAppt: Codable { let client_id: UUID }
                let isoFormatter = ISO8601DateFormatter()
                let todayISO = isoFormatter.string(from: Date())
                
                let upcomingAppts: [ClientAppt] = try await SupabaseManager.shared.client
                    .from("appointment")
                    .select("client_id")
                    .gte("timestamp", value: todayISO)
                    .execute()
                    .value
                
                let hotClientIds = Set(upcomingAppts.map { $0.client_id })
                for i in 0..<dbClients.count {
                    if hotClientIds.contains(dbClients[i].id) {
                        dbClients[i].isHot = true
                    }
                }
            } catch {
                print("Could not fetch appointments for isHot flag: \(error)")
            }
            
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
            let highnetworthCount = self.clients.filter { $0.tier == .highnetworth }.count
            let vipCount = self.clients.filter { $0.tier == .vip }.count
            let standardCount = self.clients.filter { $0.tier == .standard }.count
            
            self.stats = [
                ClientStat(value: "\(totalCount)", label: "Total"),
                ClientStat(value: "\(highnetworthCount)", label: "High Networth"),
                ClientStat(value: "\(vipCount)", label: "VIP"),
                ClientStat(value: "\(standardCount)", label: "Standard")
            ]
            isLoading = false
        }
    }
    
    @MainActor
    func removeClient(id: UUID) {
        clients.removeAll { $0.id == id }
        
        let totalCount = self.clients.count
        let highnetworthCount = self.clients.filter { $0.tier == .highnetworth }.count
        let vipCount = self.clients.filter { $0.tier == .vip }.count
        let standardCount = self.clients.filter { $0.tier == .standard }.count
        
        self.stats = [
            ClientStat(value: "\(totalCount)", label: "Total"),
            ClientStat(value: "\(highnetworthCount)", label: "High Networth"),
            ClientStat(value: "\(vipCount)", label: "VIP"),
            ClientStat(value: "\(standardCount)", label: "Standard")
        ]
    }
}
