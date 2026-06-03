//
//  SellingViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class SellingViewModel {
    var searchText: String = ""
    var selectedCategory: CatalogCategory? = nil
    let categories: [CatalogCategory] = CatalogCategory.allCases
    
    var catalogs: [CatalogEntity] = []
    var availableStock: [UUID: Int] = [:]
    private let catalogService = CatalogService()
    
    var isLoading = false
    var errorMessage: String?
    
    var filteredCatalogs: [CatalogEntity] {
        var filtered = catalogs
        if let cat = selectedCategory {
            filtered = filtered.filter { $0.category == cat }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.brand.localizedCaseInsensitiveContains(searchText) }
        }
        return filtered
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched = try await catalogService.fetchCatalogs()
                
                var stockDict: [UUID: Int] = [:]
                if let profileTuple = try? await ProfileService().fetchCurrentProfile(),
                   let staff = profileTuple.1 as? StaffModel,
                   let boutiqueId = staff.boutiqueId {
                    stockDict = try await InventoryService.shared.fetchAvailableStockDictionary(forBoutique: boutiqueId)
                }
                
                await MainActor.run {
                    self.catalogs = fetched
                    self.availableStock = stockDict
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = String(localized: "Failed to load catalogs: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
}
