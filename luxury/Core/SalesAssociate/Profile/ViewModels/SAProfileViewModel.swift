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
    var store: String = "Maison Mumbai"
    var greeting: String = "Good morning,"
    var name: String = "Arjun Singh."
    
    var revenue: Double = 0.0
    var target: Double = 400000.0
    var progress: Double { target > 0 ? revenue / target : 0 }
    
    var statClients: String = "0"
    var statTransactions: String = "0"
    var statAppts: String { "\(appointments.count)" }
    
    var appointments: [AppointmentEntity] = []
    
    var recentClients: [SADashClient] = []
    var recentTransactions: [SATransactionEntity] = []
    
    func fetchAppointments() async {
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let staff = profile as? StaffModel {
                
                let fetched: [AppointmentEntity] = try await SupabaseManager.shared.client
                    .from("appointment")
                    .select()
                    .eq("assigned_to", value: staff.id)
                    .order("timestamp", ascending: false)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.appointments = fetched
                }
                
                await fetchStats(staffId: staff.id)
            }
        } catch {
            print("Failed to fetch appointments for SA profile: \(error)")
        }
    }
    
    private func fetchStats(staffId: UUID) async {
        do {
            let txs: [SATransactionEntity] = try await SupabaseManager.shared.client
                .from("transaction")
                .select("*, client:client_id(*)")
                .eq("staff_id", value: staffId)
                .order("date_of_transaction", ascending: false)
                .execute()
                .value
            
            let totalRevenue = txs.reduce(0.0) { $0 + $1.transactionAmount }
            
            // Extract unique clients
            var seenClients = Set<UUID>()
            var mappedClients: [SADashClient] = []
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            
            for tx in txs {
                guard let client = tx.client else { continue }
                if !seenClients.contains(client.id) {
                    seenClients.insert(client.id)
                    let visitStr = tx.dateOfTransaction.map { formatter.string(from: $0) } ?? "Unknown"
                    let initial = String(client.name.prefix(1)).uppercased()
                    let dashClient = SADashClient(
                        name: client.name,
                        tier: client.tier ?? "Standard",
                        lastVisit: visitStr,
                        ltv: totalRevenue, // simplified, ideally from client LTV
                        initial: initial.isEmpty ? "U" : initial
                    )
                    mappedClients.append(dashClient)
                }
            }
            
            await MainActor.run {
                self.revenue = totalRevenue
                self.statTransactions = "\(txs.count)"
                self.statClients = "\(mappedClients.count)"
                self.recentClients = mappedClients
                self.recentTransactions = txs
            }
        } catch {
            print("Failed to fetch stats: \(error)")
        }
    }
}
