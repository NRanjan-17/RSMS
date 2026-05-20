//
//  TeamViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class TeamViewModel {
    var storeTarget: String = "₹0"
    var storeTotal: String = "₹0"
    var storePct: Double = 0.0
    
    var staff: [BMStaffMember] = []
    var pendingAssociates: [SalesAssociate] = []
    var pendingControllers: [InventoryController] = []
    
    var isLoading = false
    var actionStaffId: UUID?
    var errorMessage: String?
    
    private let profileService = ProfileService()
    private let approvalService = ApprovalService()
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                guard let (_, profile) = try await profileService.fetchCurrentProfile(),
                      let manager = profile as? CorporateBoutique else {
                    throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Manager profile not found"])
                }
                
                let boutiqueId = manager.id
                
                let saPending = try await approvalService.fetchPendingStaff(for: boutiqueId)
                let icPending = try await approvalService.fetchPendingInventoryControllers(for: boutiqueId)
                
                await MainActor.run {
                    self.pendingAssociates = saPending
                    self.pendingControllers = icPending
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch team data: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func approveAssociate(_ associate: SalesAssociate, completion: @escaping () -> Void = {}) {
        updateStaff(id: associate.id, action: { try await self.approvalService.approveSalesAssociate(id: associate.id) }, completion: completion)
    }
    
    func rejectAssociate(_ associate: SalesAssociate, completion: @escaping () -> Void = {}) {
        updateStaff(id: associate.id, action: { try await self.approvalService.rejectSalesAssociate(id: associate.id) }, completion: completion)
    }
    
    func approveController(_ controller: InventoryController, completion: @escaping () -> Void = {}) {
        updateStaff(id: controller.id, action: { try await self.approvalService.approveInventoryController(id: controller.id) }, completion: completion)
    }
    
    func rejectController(_ controller: InventoryController, completion: @escaping () -> Void = {}) {
        updateStaff(id: controller.id, action: { try await self.approvalService.rejectInventoryController(id: controller.id) }, completion: completion)
    }
    
    private func updateStaff(id: UUID, action: @escaping () async throws -> Void, completion: @escaping () -> Void) {
        actionStaffId = id
        errorMessage = nil
        
        Task {
            do {
                try await action()
                await MainActor.run {
                    self.actionStaffId = nil
                    fetchData()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.actionStaffId = nil
                    self.errorMessage = "Failed to update staff request: \(error.localizedDescription)"
                }
            }
        }
    }
}
