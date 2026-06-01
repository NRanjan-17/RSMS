import Foundation
import Observation
import Supabase
import PostgREST

@Observable
final class SalesTargetsViewModel {
    var isLoading = false
    var isSaving = false
    var boutique: CorporateBoutique?
    var staffMembers: [StaffModel] = []
    var saveSuccessMessage: String?
    
    // Local edits
    var editedBoutiqueTarget: String = ""
    var editedStaffTargets: [UUID: String] = [:]
    
    func fetchData() async {
        isLoading = true
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let corporateBoutique = profile as? CorporateBoutique {
                
                await MainActor.run {
                    self.boutique = corporateBoutique
                    self.editedBoutiqueTarget = corporateBoutique.dailySalesTarget != nil ? String(format: "%.0f", corporateBoutique.dailySalesTarget!) : ""
                }
                
                let fetchedStaff: [StaffModel] = try await SupabaseManager.shared.client
                    .from("staff")
                    .select()
                    .eq("boutique_id", value: corporateBoutique.id)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.staffMembers = fetchedStaff
                    for staff in fetchedStaff {
                        if let target = staff.dailySalesTarget {
                            self.editedStaffTargets[staff.id] = String(format: "%.0f", target)
                        } else {
                            self.editedStaffTargets[staff.id] = ""
                        }
                    }
                    self.isLoading = false
                }
            } else {
                await MainActor.run { isLoading = false }
            }
        } catch {
            print("Failed to fetch targets: \(error)")
            await MainActor.run { isLoading = false }
        }
    }
    
    func saveTargets() async {
        guard let boutique = boutique else { return }
        isSaving = true
        
        do {
            let bTarget = Double(editedBoutiqueTarget.replacingOccurrences(of: ",", with: ""))
            
            struct UpdateBoutiqueTarget: Codable {
                let daily_sales_target: Double?
            }
            
            let bUpdate = UpdateBoutiqueTarget(daily_sales_target: bTarget)
            try await SupabaseManager.shared.client
                .from("boutiques")
                .update(bUpdate)
                .eq("id", value: boutique.id)
                .execute()
            
            for staff in staffMembers {
                let sTargetText = editedStaffTargets[staff.id] ?? ""
                let sTarget = Double(sTargetText.replacingOccurrences(of: ",", with: ""))
                
                struct UpdateStaffTarget: Codable {
                    let daily_sales_target: Double?
                }
                let sUpdate = UpdateStaffTarget(daily_sales_target: sTarget)
                
                try await SupabaseManager.shared.client
                    .from("staff")
                    .update(sUpdate)
                    .eq("id", value: staff.id)
                    .execute()
            }
            
            await MainActor.run {
                self.saveSuccessMessage = "Targets updated successfully."
                self.isSaving = false
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run { self.saveSuccessMessage = nil }
            
        } catch {
            print("Failed to save targets: \(error)")
            await MainActor.run { isSaving = false }
        }
    }
}
