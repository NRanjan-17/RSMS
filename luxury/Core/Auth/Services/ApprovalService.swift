//
//  ApprovalService.swift
//  luxury
//
//  Created by Aditya Chauhan on 19/05/26.
//

import Foundation
import Supabase

final class ApprovalService {
    private let client = SupabaseManager.shared.client
    
    func fetchPendingBoutiques() async throws -> [CorporateBoutique] {
        let boutiques: [CorporateBoutique] = try await client.from("boutiques").select().eq("status", value: "pending").execute().value
        return boutiques.filter { !$0.isRegistrationIncomplete }
    }
    
    func fetchApprovedBoutiques() async throws -> [CorporateBoutique] {
        let boutiques: [CorporateBoutique] = try await client.from("boutiques").select().eq("status", value: "approved").execute().value
        return boutiques.filter { !$0.isRegistrationIncomplete }
    }
    
    func fetchPendingStaff(for boutiqueId: UUID) async throws -> [SalesAssociate] {
        let associates: [SalesAssociate] = try await client.from("sales_associates").select().eq("boutique_id", value: boutiqueId).eq("status", value: "pending").execute().value
        return associates.filter { !$0.isRegistrationIncomplete }
    }
    
    func fetchPendingInventoryControllers(for boutiqueId: UUID) async throws -> [InventoryController] {
        let controllers: [InventoryController] = try await client.from("inventory_controllers").select().eq("boutique_id", value: boutiqueId).eq("status", value: "pending").execute().value
        return controllers.filter { !$0.isRegistrationIncomplete }
    }
    
    func approveBoutique(id: UUID) async throws {
        try await updateBoutiqueStatus(id: id, status: .approved)
    }
    
    func rejectBoutique(id: UUID) async throws {
        try await updateBoutiqueStatus(id: id, status: .rejected)
    }
    
    func approveSalesAssociate(id: UUID) async throws {
        try await updateStaffStatus(table: "sales_associates", id: id, status: .approved)
    }
    
    func rejectSalesAssociate(id: UUID) async throws {
        try await updateStaffStatus(table: "sales_associates", id: id, status: .rejected)
    }
    
    func approveInventoryController(id: UUID) async throws {
        try await updateStaffStatus(table: "inventory_controllers", id: id, status: .approved)
    }
    
    func rejectInventoryController(id: UUID) async throws {
        try await updateStaffStatus(table: "inventory_controllers", id: id, status: .rejected)
    }
    
    private func updateBoutiqueStatus(id: UUID, status: EntityStatus) async throws {
        try await client.from("boutiques").update(["status": status.rawValue]).eq("id", value: id).execute()
    }
    
    private func updateStaffStatus(table: String, id: UUID, status: EntityStatus) async throws {
        try await client.from(table).update(["status": status.rawValue]).eq("id", value: id).execute()
    }
}
