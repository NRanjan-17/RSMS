//
//  AppointmentsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class AppointmentsViewModel {
    var appointments: [AppointmentEntity] = []
    var isLoading = false
    var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    private let profileService = ProfileService()
    
    var currentMonthDays: [(Int, String, String)] = {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        return range.map { day -> (Int, String, String) in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            let date = calendar.date(from: components)!
            let weekdayStr = formatter.string(from: date)
            return (day, weekdayStr, "\(day)")
        }
    }()
    
    var remainingCount: Int {
        appointments.filter { $0.status != "completed" }.count
    }
    
    @MainActor
    func fetchAppointments() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let session = try? await client.auth.session else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No active session"])
            }
            
            // First fetch the staff profile
            let staff: StaffModel = try await client.from("staff")
                .select()
                .eq("auth_user_id", value: session.user.id)
                .single()
                .execute()
                .value
            
            // Fetch appointments where the SA is the creator OR the assigned staff
            let fetched: [AppointmentEntity] = try await client.from("appointment")
                .select("*, client(*)")
                .or("created_by.eq.\(staff.id),assigned_to.eq.\(staff.id)")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.appointments = fetched
        } catch {
            print("Failed to fetch appointments: \(error)")
            self.errorMessage = error.localizedDescription
            self.appointments = []
        }
        isLoading = false
    }
}
