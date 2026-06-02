import Foundation
import Observation

@Observable
final class SalesProductDetailViewModel {
    var recommendations: [CatalogEntity] = []
    var isLoadingRecommendations = false
    
    private let catalogService = CatalogService()
    
    func fetchRecommendations(for catalog: CatalogEntity) {
        isLoadingRecommendations = true
        Task {
            do {
                // Fetch catalogs of the same category, excluding the current one
                let allCatalogs = try await catalogService.fetchCatalogs()
                
                // Use AI Recommendation Engine to find true cross-selling pairings
                let recommended = await RecommendationEngine.shared.suggestRelatedProducts(for: catalog, catalog: allCatalogs, limit: 3)
                
                await MainActor.run {
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
