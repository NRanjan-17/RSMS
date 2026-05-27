import SwiftUI
import Observation
import Supabase

@Observable
final class BarcodeLookupViewModel {
    var isLoading = false
    var errorMessage: String?
    var scannedItem: CatalogEntity?
    var liveStockCount: Int = 0
    
    private let profileService = ProfileService()
    
    func lookupItem(by code: String) {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        scannedItem = nil
        liveStockCount = 0
        
        Task {
            do {
                // Fetch catalog item by UPC/Barcode or Catalog ID (Case Insensitive)
                let item: CatalogEntity
                do {
                    item = try await SupabaseManager.shared.client
                        .from("catalogs")
                        .select()
                        .ilike("bar_code", pattern: trimmed)
                        .single()
                        .execute()
                        .value
                } catch {
                    item = try await SupabaseManager.shared.client
                        .from("catalogs")
                        .select()
                        .ilike("catalog_id", pattern: trimmed)
                        .single()
                        .execute()
                        .value
                }
                
                // Get current store ID from user profile
                var boutiqueId: UUID? = nil
                if let profileTuple = try? await profileService.fetchCurrentProfile(),
                   let staff = profileTuple.1 as? StaffModel {
                    boutiqueId = staff.boutiqueId
                }
                
                // Fetch localized inventory for this store
                var localizedStockCount = 0
                if let storeId = boutiqueId {
                    if let inventory: [InventoryItem] = try? await SupabaseManager.shared.client
                        .from("inventory")
                        .select()
                        .eq("sku_id", value: item.id)
                        .eq("store_id", value: storeId)
                        .execute()
                        .value, let firstItem = inventory.first {
                        localizedStockCount = firstItem.quantity
                    }
                }
                
                await MainActor.run {
                    self.scannedItem = item
                    self.liveStockCount = localizedStockCount
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Item not found for barcode: \(trimmed)"
                    self.isLoading = false
                }
            }
        }
    }
}
