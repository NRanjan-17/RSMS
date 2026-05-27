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
    
    func fetchAppointments() async {
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let staff = profile as? StaffModel {
                
                let fetched: [AppointmentEntity] = try await SupabaseManager.shared.client
                    .from("appointment")
                    .select()
                    .eq("assigned_staff_id", value: staff.id)
                    .order("appointment_date", ascending: false)
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
}
