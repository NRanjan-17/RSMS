//
//  RegistrationViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 19/05/26.
//

import SwiftUI
import Observation
import PhotosUI
import Supabase

@Observable
final class RegistrationViewModel {
    var name = ""
    var email = ""
    var phone = ""
    var address = ""
    var password = ""
    var acceptedTerms = false
    
    var boutiqueName = ""
    var city = ""
    var pinCode = ""
    
    var selectedBoutiqueId: UUID?
    var avatarImage: PickedImageAsset?
    var resumeImage: PickedImageAsset?
    
    var isLoading = false
    var errorMessage: String?
    
    private let authService = AuthService()
    private let storageService = StorageService()
    private let imagePickerService = ImagePickerService()
    private let client = SupabaseManager.shared.client
    
    var boutiques: [CorporateBoutique] = []
    
    private struct BoutiqueUpdate: Encodable {
        let name: String
        let manager_name: String
        let address: String
        let city: String
        let pin_code: String
        let manager_phone: String
        let provider: String
        let updated_at: Date
    }
    
    private struct StaffUpdate: Encodable {
        let name: String
        let boutique_id: UUID
        let phone: String
        let address: String
        let location: String
        let city: String
        let pin_code: String
        let resume_url: String
        let avatar_url: String
        let provider: String
        let updated_at: Date
    }
    
    private struct StaffInsert: Encodable {
        let id: UUID
        let auth_user_id: UUID
        let boutique_id: UUID
        let employee_id: String
        let name: String
        let email: String
        let phone: String
        let address: String
        let location: String
        let city: String
        let pin_code: String
        let resume_url: String
        let avatar_url: String
        let provider: String
        let status: EntityStatus
        let created_at: Date
        let updated_at: Date
    }
    
    private struct SavedApplicationID: Decodable {
        let id: UUID
    }
    
    func loadUserData() {
        Task {
            let session = await authService.getCurrentSession()
            await MainActor.run {
                self.email = session?.user.email ?? ""
                self.password = "••••••••"
                if let tempName = UserDefaults.standard.string(forKey: "temp_reg_name") {
                    self.name = tempName
                } else {
                    self.name = session?.user.userMetadata["full_name"]?.stringValue ?? ""
                }
            }
        }
    }
    
    func fetchBoutiques() {
        Task {
            do {
                let fetched: [CorporateBoutique] = try await client.from("boutiques").select().eq("status", value: "approved").execute().value
                await MainActor.run {
                    self.boutiques = fetched
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load approved boutiques."
                }
            }
        }
    }
    
    func selectBoutique(_ boutique: CorporateBoutique) {
        selectedBoutiqueId = boutique.id
        city = boutique.city
    }
    
    func pickAvatar(from item: PhotosPickerItem?) {
        Task {
            do {
                let image = try await imagePickerService.loadImage(from: item)
                await MainActor.run {
                    self.avatarImage = image
                    self.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func pickResume(from item: PhotosPickerItem?) {
        Task {
            do {
                let image = try await imagePickerService.loadImage(from: item)
                await MainActor.run {
                    self.resumeImage = image
                    self.errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func submitApplication(role: UserRole, completion: @escaping () -> Void) {
        print("Registration submit tapped for role: \(role.rawValue)")
        
        guard validateApplication(role: role) else {
            print("Registration validation failed: \(errorMessage ?? "Unknown validation error")")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let session = await authService.getCurrentSession()
                guard let userId = session?.user.id else {
                    throw validationError("Failed to retrieve user ID.")
                }
                guard let sessionEmail = session?.user.email?.trimmed, !sessionEmail.isEmpty else {
                    throw validationError("Failed to retrieve account email.")
                }
                
                let provider = session?.user.userMetadata["provider"]?.stringValue ?? "email"
                
                var avatarUrl = ""
                if let image = avatarImage {
                    print("Registration uploading avatar image")
                    avatarUrl = try await storageService.uploadAvatar(image: image, userId: userId)
                    print("Registration uploaded avatar image")
                }
                
                var resumeUrl = ""
                if let image = resumeImage {
                    print("Registration uploading resume image")
                    resumeUrl = try await storageService.uploadResume(image: image, userId: userId)
                    print("Registration uploaded resume image")
                }
                
                switch role {
                case .boutiqueManager:
                    let updated = try await submitBoutiqueApplication(
                        sessionEmail: sessionEmail,
                        provider: provider
                    )
                    print("Registration saved boutique application: \(updated.id)")
                    
                case .salesAssociate:
                    guard let selectedBoutiqueId else {
                        throw validationError("Please select an approved boutique.")
                    }
                    let saved = try await submitStaffApplication(
                        table: "sales_associates",
                        userId: userId,
                        email: sessionEmail,
                        boutiqueId: selectedBoutiqueId,
                        avatarUrl: avatarUrl,
                        resumeUrl: resumeUrl,
                        provider: provider
                    )
                    print("Registration saved sales associate application: \(saved.id)")
                    
                case .inventoryController:
                    guard let selectedBoutiqueId else {
                        throw validationError("Please select an approved boutique.")
                    }
                    let saved = try await submitStaffApplication(
                        table: "inventory_controllers",
                        userId: userId,
                        email: sessionEmail,
                        boutiqueId: selectedBoutiqueId,
                        avatarUrl: avatarUrl,
                        resumeUrl: resumeUrl,
                        provider: provider
                    )
                    print("Registration saved inventory controller application: \(saved.id)")
                    
                case .corporateAdmin:
                    throw validationError("Corporate admin registration is not available.")
                }
                
                await MainActor.run {
                    UserDefaults.standard.removeObject(forKey: "temp_reg_name")
                    isLoading = false
                    print("Registration submit completed for role: \(role.rawValue)")
                    completion()
                }
            } catch {
                let message = "Application submission failed: \(error.localizedDescription)"
                print("Registration submit error: \(message)")
                print("Registration submit raw error: \(error)")
                await MainActor.run {
                    isLoading = false
                    errorMessage = message
                }
            }
        }
    }
    
    private func submitStaffApplication(
        table: String,
        userId: UUID,
        email: String,
        boutiqueId: UUID,
        avatarUrl: String,
        resumeUrl: String,
        provider: String
    ) async throws -> SavedApplicationID {
        let update = StaffUpdate(
            name: name.trimmed,
            boutique_id: boutiqueId,
            phone: phone.trimmed,
            address: address.trimmed,
            location: city.trimmed,
            city: city.trimmed,
            pin_code: pinCode.trimmed,
            resume_url: resumeUrl,
            avatar_url: avatarUrl,
            provider: provider,
            updated_at: Date()
        )
        
        if let existing = try await findStaffApplicationId(table: table, userId: userId) {
            return try await client.from(table)
                .update(update)
                .eq("id", value: existing.id)
                .select("id")
                .single()
                .execute()
                .value
        }
        
        let insert = StaffInsert(
            id: UUID(),
            auth_user_id: userId,
            boutique_id: boutiqueId,
            employee_id: "TEMP-\(userId.uuidString.prefix(6))",
            name: name.trimmed,
            email: email,
            phone: phone.trimmed,
            address: address.trimmed,
            location: city.trimmed,
            city: city.trimmed,
            pin_code: pinCode.trimmed,
            resume_url: resumeUrl,
            avatar_url: avatarUrl,
            provider: provider,
            status: .pending,
            created_at: Date(),
            updated_at: Date()
        )
        
        return try await client.from(table)
            .insert(insert)
            .select("id")
            .single()
            .execute()
            .value
    }
    
    private func findStaffApplicationId(table: String, userId: UUID) async throws -> SavedApplicationID? {
        let matches: [SavedApplicationID] = try await client.from(table)
            .select("id")
            .eq("auth_user_id", value: userId)
            .limit(1)
            .execute()
            .value
        
        return matches.first
    }
    
    private func submitBoutiqueApplication(sessionEmail: String, provider: String) async throws -> CorporateBoutique {
        let update = BoutiqueUpdate(
            name: boutiqueName.trimmed,
            manager_name: name.trimmed,
            address: address.trimmed,
            city: city.trimmed,
            pin_code: pinCode.trimmed,
            manager_phone: phone.trimmed,
            provider: provider,
            updated_at: Date()
        )
        
        var existing = try await findBoutiqueApplication(email: sessionEmail)
        if existing == nil {
            existing = try await findBoutiqueApplication(email: email.trimmed)
        }
        
        if let existing {
            let updated: CorporateBoutique = try await client.from("boutiques")
                .update(update)
                .eq("id", value: existing.id)
                .select()
                .single()
                .execute()
                .value
            return updated
        }
        
        let boutique = CorporateBoutique(
            id: UUID(),
            name: boutiqueName.trimmed,
            managerName: name.trimmed,
            managerEmail: sessionEmail,
            managerPhone: phone.trimmed,
            address: address.trimmed,
            city: city.trimmed,
            pinCode: pinCode.trimmed,
            provider: provider,
            status: .pending,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let created: CorporateBoutique = try await client.from("boutiques")
            .insert(boutique)
            .select()
            .single()
            .execute()
            .value
        return created
    }
    
    private func findBoutiqueApplication(email: String) async throws -> CorporateBoutique? {
        let trimmedEmail = email.trimmed
        guard !trimmedEmail.isEmpty else { return nil }
        
        let matches: [CorporateBoutique] = try await client.from("boutiques")
            .select()
            .eq("manager_email", value: trimmedEmail)
            .limit(1)
            .execute()
            .value
        
        return matches.first
    }
    
    private func validateApplication(role: UserRole) -> Bool {
        guard acceptedTerms else {
            errorMessage = "Please accept the terms and conditions."
            return false
        }
        
        guard !name.trimmed.isEmpty, !email.trimmed.isEmpty, !phone.trimmed.isEmpty, !address.trimmed.isEmpty else {
            errorMessage = "Please complete all required profile fields."
            return false
        }
        
        switch role {
        case .boutiqueManager:
            guard !boutiqueName.trimmed.isEmpty, !city.trimmed.isEmpty, !pinCode.trimmed.isEmpty else {
                errorMessage = "Please complete all boutique details."
                return false
            }
        case .salesAssociate, .inventoryController:
            guard selectedBoutiqueId != nil else {
                errorMessage = "Please select an approved boutique."
                return false
            }
            guard !pinCode.trimmed.isEmpty else {
                errorMessage = "Please enter your PIN code."
                return false
            }
            guard avatarImage != nil, resumeImage != nil else {
                errorMessage = "Please attach both profile and resume images."
                return false
            }
        case .corporateAdmin:
            errorMessage = "Corporate admin registration is not available."
            return false
        }
        
        return true
    }
    
    private func validationError(_ message: String) -> NSError {
        NSError(domain: "Registration", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
