//
//  RoutingService.swift
//  luxury
//
//  Created by Aditya Chauhan on 19/05/26.
//

import SwiftUI
import Observation
import Supabase

@Observable
final class RoutingService {
    enum Destination: Equatable {
        case splash
        case auth
        case registration(UserRole)
        case status(UserRole, EntityStatus, String?)
        case dashboard(UserRole)
    }
    
    var currentDestination: Destination = .splash
    var intendedRole: UserRole?
    
    private let authService = AuthService()
    private let profileService = ProfileService()
    private let client = SupabaseManager.shared.client
    
    private var profileSubscription: RealtimeChannelV2?
    private var listeningTask: Task<Void, Never>?
    
    init() {
        observeAuth()
    }
    
    func observeAuth() {
        authService.observeAuthState { [weak self] _, session in
            Task {
                await self?.updateRoute(for: session)
                if session != nil {
                    await self?.subscribeToProfile()
                } else {
                    await self?.unsubscribeFromProfile()
                }
            }
        }
    }
    
    func subscribeToProfile() async {
        let session = await authService.getCurrentSession()
        guard let userId = session?.user.id else { return }
        
        await unsubscribeFromProfile()
        
        let channel = client.realtimeV2.channel("profile_changes")
        
        let boutiqueChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "boutiques", filter: .eq("manager_email", value: session?.user.email ?? ""))
        let associateChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "sales_associates", filter: .eq("auth_user_id", value: userId.uuidString))
        let controllerChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "inventory_controllers", filter: .eq("auth_user_id", value: userId.uuidString))
        
        listeningTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in boutiqueChanges {
                        let session = await self.authService.getCurrentSession()
                        await self.updateRoute(for: session)
                    }
                }
                group.addTask {
                    for await _ in associateChanges {
                        let session = await self.authService.getCurrentSession()
                        await self.updateRoute(for: session)
                    }
                }
                group.addTask {
                    for await _ in controllerChanges {
                        let session = await self.authService.getCurrentSession()
                        await self.updateRoute(for: session)
                    }
                }
            }
        }
        
        profileSubscription = channel
        try? await channel.subscribeWithError()
    }
    
    func unsubscribeFromProfile() async {
        listeningTask?.cancel()
        listeningTask = nil
        
        if let channel = profileSubscription {
            await channel.unsubscribe()
            profileSubscription = nil
        }
    }
    
    func updateRoute(for session: Session?) async {
        guard let session = session else {
            await MainActor.run {
                currentDestination = .auth
            }
            return
        }
        
        let roleStr = session.user.userMetadata["role"]?.stringValue
        let metadataRole = roleStr.flatMap(UserRole.init(rawValue:))
        let requestedRole = metadataRole ?? intendedRole
        
        if let currentIntended = intendedRole, let metadataRole, currentIntended != metadataRole {
            try? await authService.signOut()
            return
        }
        
        do {
            if let (role, profile) = try await profileService.fetchCurrentProfile(preferredRole: requestedRole) {
                if let currentIntended = intendedRole, currentIntended != role {
                    try? await authService.signOut()
                    return
                }
                
                if let metadataRole, metadataRole != role {
                    try? await authService.signOut()
                    return
                }
                
                let status = getStatus(from: profile)
                
                await MainActor.run {
                    if shouldCompleteRegistration(profile: profile, status: status) {
                        currentDestination = .registration(role)
                    } else if status == EntityStatus.approved {
                        currentDestination = .dashboard(role)
                    } else {
                        currentDestination = .status(role, status, nil)
                    }
                }
                
                if status != .approved, !shouldCompleteRegistration(profile: profile, status: status) {
                    let contactEmail = await managerContactEmail(for: profile)
                    await MainActor.run {
                        currentDestination = .status(role, status, contactEmail)
                    }
                }
            } else {
                await MainActor.run {
                    if let finalRole = requestedRole, finalRole != .corporateAdmin {
                        currentDestination = .registration(finalRole)
                    } else {
                        currentDestination = .auth
                    }
                }
            }
        } catch {
            await MainActor.run {
                currentDestination = .auth
            }
        }
    }
    
    private func getStatus(from profile: Any) -> EntityStatus {
        if profile is CorporateAdmin {
            return .approved
        } else if let manager = profile as? CorporateBoutique {
            return manager.status
        } else if let associate = profile as? SalesAssociate {
            return associate.status
        } else if let controller = profile as? InventoryController {
            return controller.status
        }
        return .pending
    }
    
    private func shouldCompleteRegistration(profile: Any, status: EntityStatus) -> Bool {
        guard status == .pending else { return false }
        
        if let manager = profile as? CorporateBoutique {
            return manager.isRegistrationIncomplete
        } else if let associate = profile as? SalesAssociate {
            return associate.isRegistrationIncomplete
        } else if let controller = profile as? InventoryController {
            return controller.isRegistrationIncomplete
        }
        
        return false
    }
    
    private func managerContactEmail(for profile: Any) async -> String? {
        if let associate = profile as? SalesAssociate, let boutiqueId = associate.boutiqueId {
            return try? await profileService.fetchBoutique(id: boutiqueId)?.managerEmail
        }
        
        if let controller = profile as? InventoryController, let boutiqueId = controller.boutiqueId {
            return try? await profileService.fetchBoutique(id: boutiqueId)?.managerEmail
        }
        
        return nil
    }
}
