import Foundation
import Observation

@Observable
final class SalesProductDetailViewModel {
    var recommendations: [CatalogEntity] = []
    var isLoadingRecommendations = false
    var stockCount: Int = 0
    var isStockLoading = true
    
    private let catalogService = CatalogService()
    
    func fetchRecommendations(for catalog: CatalogEntity) {
        isLoadingRecommendations = true
        isStockLoading = true
        Task {
            do {
                // Fetch catalogs of the same category, excluding the current one
                let allCatalogs = try await catalogService.fetchCatalogs()
                
                // Fetch the actual physical stock for the CURRENT logged-in boutique
                let profileTuple = try? await ProfileService().fetchCurrentProfile()
                guard let staff = profileTuple?.1 as? StaffModel, let boutiqueId = staff.boutiqueId else { return }
                let stockDict = try await InventoryService.shared.fetchAvailableStockDictionary(forBoutique: boutiqueId)
                
                // Use AI Recommendation Engine to find true cross-selling pairings inside this boutique
                let recommended = await RecommendationEngine.shared.suggestRelatedProducts(for: catalog, catalog: allCatalogs, availableStock: stockDict, limit: 3)
                
                await MainActor.run {
                    self.stockCount = stockDict[catalog.id] ?? 0
                    self.isStockLoading = false
                    self.recommendations = recommended
                    self.isLoadingRecommendations = false
                }
            } catch {
                print("Failed to fetch recommendations: \(error)")
                await MainActor.run {
                    self.isLoadingRecommendations = false
                }
            }
        }
    }
}
