//
//  ProfileService.swift
//  luxury
//
//  Created by Aditya Chauhan on 19/05/26.
//

import Foundation
import Supabase

final class ProfileService {
    private let client = SupabaseManager.shared.client
    
    func fetchCurrentProfile(preferredRole: UserRole? = nil) async throws -> (UserRole, Any)? {
        let session = try? await client.auth.session
        guard let userId = session?.user.id, let email = session?.user.email else { return nil }
        
        let roleStr = session?.user.userMetadata["role"]?.stringValue
        let metadataRole = UserRole(rawValue: roleStr ?? "")
        let role = preferredRole ?? metadataRole
        
        if role == .corporateAdmin || role == nil {
            do {
                let admin: CorporateAdmin = try await client.from("corporate_admins")
                    .select()
                    .eq("id", value: userId)
                    .single()
                    .execute()
                    .value
                return (.corporateAdmin, admin)
            } catch {}
        }
        
        if role == .boutiqueManager || role == nil {
            do {
                let manager: CorporateBoutique = try await client.from("boutiques")
                    .select()
                    .eq("manager_email", value: email)
                    .single()
                    .execute()
                    .value
                return (.boutiqueManager, manager)
            } catch {}
        }
        
        if role == .salesAssociate || role == nil {
            do {
                let associate: SalesAssociate = try await client.from("sales_associates")
                    .select()
                    .eq("auth_user_id", value: userId)
                    .single()
                    .execute()
                    .value
                return (.salesAssociate, associate)
            } catch {}
        }
        
        if role == .inventoryController || role == nil {
            do {
                let controller: InventoryController = try await client.from("inventory_controllers")
                    .select()
                    .eq("auth_user_id", value: userId)
                    .single()
                    .execute()
                    .value
                return (.inventoryController, controller)
            } catch {}
        }
        
        return nil
    }
    
    func fetchBoutique(id: UUID) async throws -> CorporateBoutique? {
        try await client.from("boutiques")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
    
    func createSkeletonProfile(userId: UUID, role: UserRole, name: String, email: String, provider: String) async throws {
        print("DEBUG: createSkeletonProfile called for uid: \(userId), role: \(role.rawValue)")
        switch role {
        case .corporateAdmin:
            let admin = CorporateAdmin(
                id: userId,
                name: name,
                email: email,
                phone: "+910000000000",
                createdAt: Date()
            )
            try await client.from("corporate_admins").upsert(admin).execute()
            print("DEBUG: Corporate Admin row upserted in DB")
            
        case .boutiqueManager:
            let boutique = CorporateBoutique(
                id: UUID(),
                name: "",
                managerName: name,
                managerEmail: email,
                managerPhone: "",
                address: "",
                city: "",
                pinCode: "",
                provider: provider,
                status: .pending,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await client.from("boutiques").upsert(boutique, onConflict: "manager_email").execute()
            print("DEBUG: Boutique Manager skeleton upserted in DB")
            
        case .salesAssociate:
            let associate = SalesAssociate(
                id: UUID(),
                authUserId: userId,
                boutiqueId: nil,
                employeeId: "TEMP-\(userId.uuidString.prefix(6))",
                name: name,
                email: email,
                phone: "",
                address: "",
                location: "",
                city: "",
                pinCode: "",
                resumeUrl: "",
                provider: provider,
                avatarUrl: "",
                status: .pending,
                createdAt: Date(),
                updatedAt: Date(),
                lastLoginAt: nil
            )
            try await client.from("sales_associates").upsert(associate, onConflict: "auth_user_id").execute()
            print("DEBUG: Sales Associate skeleton upserted in DB")
            
        case .inventoryController:
            let controller = InventoryController(
                id: UUID(),
                authUserId: userId,
                boutiqueId: nil,
                employeeId: "TEMP-\(userId.uuidString.prefix(6))",
                name: name,
                email: email,
                phone: "",
                address: "",
                location: "",
                city: "",
                pinCode: "",
                resumeUrl: "",
                provider: provider,
                avatarUrl: "",
                certificationUrl: nil,
                status: .pending,
                createdAt: Date(),
                updatedAt: Date(),
                lastLoginAt: nil
            )
            try await client.from("inventory_controllers").upsert(controller, onConflict: "auth_user_id").execute()
            print("DEBUG: Inventory Controller skeleton upserted in DB")
        }
    }
}
