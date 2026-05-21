//
//  UserManagementViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI
import Observation
import Supabase

@Observable
final class UserManagementViewModel {
    var searchText: String = ""
    var isLoading = false
    var actionBoutiqueId: UUID?
    var actionErrorMessage: String?
    var errorMessage: String?
    
    var pendingBoutiques: [CorporateBoutique] = []
    var approvedBoutiques: [CorporateBoutique] = []
    
    private let approvalService = ApprovalService()
    
    var filteredApprovedBoutiques: [CorporateBoutique] {
        if searchText.isEmpty {
            return approvedBoutiques
        }
        return approvedBoutiques.filter { boutique in
            boutique.name.localizedCaseInsensitiveContains(searchText) ||
            boutique.managerName.localizedCaseInsensitiveContains(searchText) ||
            boutique.managerPhone.localizedCaseInsensitiveContains(searchText) ||
            boutique.city.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let pendingTask = approvalService.fetchPendingBoutiques()
                async let approvedTask = approvalService.fetchApprovedBoutiques()
                
                let (pending, approved) = try await (pendingTask, approvedTask)
                
                await MainActor.run {
                    self.pendingBoutiques = pending
                    self.approvedBoutiques = approved
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch user management data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func approveBoutique(_ boutique: CorporateBoutique, completion: @escaping () -> Void = {}) {
        actionBoutiqueId = boutique.id
        actionErrorMessage = nil
        errorMessage = nil
        
        Task {
            do {
                try await approvalService.approveBoutique(id: boutique.id)
                await MainActor.run {
                    self.pendingBoutiques.removeAll { $0.id == boutique.id }
                    self.actionBoutiqueId = nil
                    fetchData()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.actionBoutiqueId = nil
                    self.actionErrorMessage = "Approval failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func rejectBoutique(_ boutique: CorporateBoutique, completion: @escaping () -> Void = {}) {
        actionBoutiqueId = boutique.id
        actionErrorMessage = nil
        errorMessage = nil
        
        Task {
            do {
                try await approvalService.rejectBoutique(id: boutique.id)
                await MainActor.run {
                    self.pendingBoutiques.removeAll { $0.id == boutique.id }
                    self.actionBoutiqueId = nil
                    fetchData()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.actionBoutiqueId = nil
                    self.actionErrorMessage = "Rejection failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func inviteBoutique(email: String) async throws {
        let profileService = ProfileService()
        try await profileService.createSkeletonProfile(
            userId: UUID(),
            role: .boutiqueManager,
            name: "",
            email: email,
            provider: "email"
        )
    }
}
