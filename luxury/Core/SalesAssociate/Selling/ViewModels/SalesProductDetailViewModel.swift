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
                
                let filtered = allCatalogs.filter { 
                    $0.category == catalog.category && $0.id != catalog.id 
                }
                
                // Shuffle and pick up to 3 recommendations
                let recommended = Array(filtered.shuffled().prefix(3))
                
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
