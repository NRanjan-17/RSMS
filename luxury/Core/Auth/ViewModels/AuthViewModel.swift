import SwiftUI
import Observation
import Supabase

@Observable
final class AuthViewModel {
    var isSignUp = false
    var name = ""
    var email = ""
    var password = ""
    var isLoading = false
    var errorMessage: String?
    var showResetSuccess = false
    
    private let authService = AuthService()
    private let profileService = ProfileService()
    
    func authenticate(selectedRole: UserRole, onSuccess: @escaping () -> Void) {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty && !trimmedPassword.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        if isSignUp {
            guard !name.isEmpty else {
                errorMessage = "Please enter your name."
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    let metadata: [String: AnyJSON] = [
                        "role": .string(selectedRole.rawValue),
                        "provider": .string("email"),
                        "full_name": .string(name)
                    ]
                    let user = try await authService.signUp(email: trimmedEmail, password: trimmedPassword, data: metadata)
                    try await profileService.createSkeletonProfile(userId: user.id, role: selectedRole, name: name, email: trimmedEmail, provider: "email")
                    UserDefaults.standard.set(name, forKey: "temp_reg_name")
                } else {
                    try await authService.signIn(email: trimmedEmail, password: trimmedPassword)
                    let session = await authService.getCurrentSession()
                    try await validateRole(session: session, selectedRole: selectedRole)
                }
                
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginSocial(provider: String, selectedRole: UserRole, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                let session = await authService.getCurrentSession()
                
                if let roleStr = session?.user.userMetadata["role"]?.stringValue {
                    if roleStr != selectedRole.rawValue {
                        try await authService.signOut()
                        throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account registered as \(roleStr)."])
                    }
                } else {
                    let metadata: [String: AnyJSON] = [
                        "role": .string(selectedRole.rawValue),
                        "provider": .string(provider.lowercased())
                    ]
                    try await authService.updateUserMetadata(data: metadata)
                    
                    if let user = session?.user {
                        let fullName = user.userMetadata["full_name"]?.stringValue ?? ""
                        let userEmail = user.email ?? ""
                        try await profileService.createSkeletonProfile(userId: user.id, role: selectedRole, name: fullName, email: userEmail, provider: provider.lowercased())
                    }
                }
                
                await MainActor.run {
                    isLoading = false
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func validateRole(session: Session?, selectedRole: UserRole) async throws {
        if let roleStr = session?.user.userMetadata["role"]?.stringValue {
            guard roleStr == selectedRole.rawValue else {
                try await authService.signOut()
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account registered as \(roleStr)."])
            }
        }
        
        if selectedRole == .corporateAdmin {
            guard let (role, _) = try await profileService.fetchCurrentProfile(preferredRole: .corporateAdmin),
                  role == .corporateAdmin else {
                try await authService.signOut()
                throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Corporate admin account not found."])
            }
            return
        }
        
        if let (role, _) = try await profileService.fetchCurrentProfile(preferredRole: selectedRole), role != selectedRole {
            try await authService.signOut()
            throw NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Account registered as \(role.rawValue)."])
        }
    }
    
    func resetPassword() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.resetPassword(email: trimmedEmail)
                await MainActor.run {
                    isLoading = false
                    showResetSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
