//
//  RFIDViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class RFIDViewModel {
    var recentSessions: [ScanSession] = []
    
    var catalogs: [CatalogEntity] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    func fetchCatalogs() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                await MainActor.run {
                    self.catalogs = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func saveScannedItems(to catalog: CatalogEntity, serials: [String], completion: @escaping () -> Void) {
        Task {
            do {
                var currentSerials = catalog.productIds ?? []
                currentSerials.append(contentsOf: serials)
                
                try await SupabaseManager.shared.client
                    .from("catalogs")
                    .update(["product_ids": currentSerials])
                    .eq("id", value: catalog.id)
                    .execute()
                
                await MainActor.run {
                    // Update local catalog
                    if let index = self.catalogs.firstIndex(where: { $0.id == catalog.id }) {
                        var updatedCatalog = catalog
                        updatedCatalog.productIds = currentSerials
                        self.catalogs[index] = updatedCatalog
                    }
                    
                    // Add session to recent history
                    let newSession = ScanSession(
                        date: "Just Now",
                        zone: "Addition: \(catalog.name)",
                        scannedCount: serials.count,
                        expectedCount: serials.count,
                        variance: 0
                    )
                    self.recentSessions.insert(newSession, at: 0)
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to save items: \(error.localizedDescription)"
                }
            }
        }
    }
}
