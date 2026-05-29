import Foundation
import Observation
import Supabase

@Observable
final class SharedProfileViewModel {
    var name: String = ""
    var email: String = ""
    var phone: String = ""
    var roleName: String = ""
    var avatarUrl: String?
    var isLoading = false
    
    private let profileService = ProfileService()
    
    func fetchProfile() async {
        isLoading = true
        do {
            if let (role, profile) = try await profileService.fetchCurrentProfile() {
                await MainActor.run {
                    self.roleName = role.rawValue
                    if let admin = profile as? CorporateAdmin {
                        self.name = admin.name
                        self.email = admin.email
                        self.phone = admin.phone
                        self.avatarUrl = nil // No avatarUrl on admin for now
                    } else if let bm = profile as? CorporateBoutique {
                        self.name = bm.managerName
                        self.email = bm.managerEmail
                        self.phone = bm.managerPhone
                        self.avatarUrl = nil
                    } else if let staff = profile as? StaffModel {
                        self.name = staff.name
                        self.email = staff.email
                        self.phone = staff.phone
                        self.avatarUrl = staff.avatarUrl
                    }
                    self.isLoading = false
                }
            }
        } catch {
            print("Failed to fetch profile: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
}
