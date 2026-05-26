//
//  CAStaffListViewModel.swift
//  luxury
//

import SwiftUI
import Observation
import Supabase

@Observable
final class CAStaffListViewModel {
    var staffMembers: [StaffModel] = []
    var isLoading = false
    var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    func fetchStaff() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Fetch staff across all boutiques managed by corporate admin
                let response: [StaffModel] = try await client.from("staff").select().execute().value
                await MainActor.run {
                    self.staffMembers = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch staff: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
