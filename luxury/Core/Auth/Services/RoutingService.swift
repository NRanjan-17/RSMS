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
                let activeSession = (session?.isExpired == true) ? nil : session
                await self?.updateRoute(for: activeSession)
                if activeSession != nil {
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
        let staffChanges = channel.postgresChange(AnyAction.self, schema: "public", table: "staff", filter: .eq("auth_user_id", value: userId.uuidString))
        
        listeningTask = Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    for await _ in boutiqueChanges {
                        let session = await self.authService.getCurrentSession()
                        await self.updateRoute(for: session)
                    }
                }
                group.addTask {
                    for await _ in staffChanges {
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
        guard let session = session, !session.isExpired else {
            await MainActor.run {
                currentDestination = .auth
            }
            return
        }
        
        let roleStr = session.user.userMetadata["role"]?.stringValue
        let metadataRole = roleStr.flatMap(UserRole.init(rawValue:))
        
        guard let requestedRole = metadataRole else {
            try? await authService.signOut()
            return
        }
        
        do {
            if let (role, profile) = try await profileService.fetchCurrentProfile(preferredRole: requestedRole) {
                if requestedRole != role {
                    try? await authService.signOut()
                    return
                }
                
                let status = getStatus(from: profile)
                
                await MainActor.run {
                    if shouldCompleteRegistration(profile: profile) {
                        currentDestination = .registration(role)
                    } else if status == EntityStatus.approved {
                        currentDestination = .dashboard(role)
                    } else {
                        currentDestination = .status(role, status, nil)
                    }
                }
                
                if status != .approved, !shouldCompleteRegistration(profile: profile) {
                    let contactEmail = await managerContactEmail(for: profile)
                    await MainActor.run {
                        currentDestination = .status(role, status, contactEmail)
                    }
                }
            } else {
                await MainActor.run {
                    if requestedRole != .corporateAdmin {
                        currentDestination = .registration(requestedRole)
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
        } else if let staff = profile as? StaffModel {
            return staff.status
        }
        return .pending
    }
    
    private func shouldCompleteRegistration(profile: Any) -> Bool {
        if let manager = profile as? CorporateBoutique {
            return !manager.onBoardingCompleted
        } else if let staff = profile as? StaffModel {
            return !staff.onBoardingCompleted
        }
        return false
    }
    
    private func managerContactEmail(for profile: Any) async -> String? {
        if let staff = profile as? StaffModel, let boutiqueId = staff.boutiqueId {
            return try? await profileService.fetchBoutique(id: boutiqueId)?.managerEmail
        }
        
        return nil
    }
}
