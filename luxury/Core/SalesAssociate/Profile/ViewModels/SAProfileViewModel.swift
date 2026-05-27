//
//  SAProfileViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class SAProfileViewModel {
    var store: String = "Boutique"
    var greeting: String = "Good morning,"
    var name: String = "Staff Member"
    
    var revenue: Double = 0.0
    var target: Double = 400000.0
    var progress: Double { target > 0 ? revenue / target : 0 }
    
    var statClients: String = "0"
    var statTransactions: String = "0"
    var statAppts: String { "\(appointments.count)" }
    
    var appointments: [AppointmentEntity] = []
    
    var recentClients: [SADashClient] = []
    
    func fetchAppointments() async {
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let staff = profile as? StaffModel {
                
                await MainActor.run {
                    self.name = staff.name
                    self.greeting = self.getGreeting() + ","
                }
                
                if let boutiqueId = staff.boutiqueId {
                    struct MinimalBoutique: Codable { let name: String }
                    if let boutiques: [MinimalBoutique] = try? await SupabaseManager.shared.client
                        .from("boutiques")
                        .select("name")
                        .eq("id", value: boutiqueId)
                        .execute()
                        .value, let b = boutiques.first {
                        await MainActor.run {
                            self.store = b.name
                        }
                    }
                }
                
                let fetched: [AppointmentEntity] = try await SupabaseManager.shared.client
                    .from("appointment")
                    .select("*, client(*)")
                    .eq("assigned_to", value: staff.id)
                    .order("timestamp", ascending: false)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.appointments = fetched
                }
                
                await fetchStats(staffId: staff.id)
                await fetchRecentClients()
            }
        } catch {
            print("Failed to fetch appointments for SA profile: \(error)")
        }
    }
    
    private func fetchStats(staffId: UUID) async {
        do {
            let orders: [OrderEntity] = try await SupabaseManager.shared.client
                .from("order")
                .select()
                .eq("rsms_user_id", value: staffId)
                .execute()
                .value
            
            let totalRevenue = orders.reduce(0.0) { $0 + $1.totalPrice }
            
            let clients: [ClientEntity] = try await SupabaseManager.shared.client
                .from("client")
                .select()
                .execute()
                .value
            
            await MainActor.run {
                self.revenue = totalRevenue
                self.statTransactions = "\(orders.count)"
                self.statClients = "\(clients.count)"
            }
        } catch {
            print("Failed to fetch stats: \(error)")
        }
    }
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private func fetchRecentClients() async {
        do {
            let service = ClientService()
            let allClients = try await service.fetchClients()
            let sorted = allClients.sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
            let recent = Array(sorted.prefix(5))
            
            let dashClients = recent.map { c in
                SADashClient(
                    name: c.name,
                    tier: c.tier ?? "Standard",
                    lastVisit: "Unknown",
                    ltv: 0.0,
                    initial: String(c.name.prefix(1))
                )
            }
            await MainActor.run {
                self.recentClients = dashClients
            }
        } catch {
            print("Failed to fetch recent clients: \(error)")
        }
    }
}
