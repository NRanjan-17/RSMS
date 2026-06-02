import Foundation
import SwiftUI
import Observation
import Supabase
import PostgREST

@Observable
final class RecommendationViewModel {
    var recommendations: [CatalogEntity] = []
    var insight: String = ""
    var isLoading: Bool = false
    var error: String? = nil
    
    private let client: Client
    
    init(client: Client) {
        self.client = client
    }
    
    @MainActor
    func loadRecommendations() async {
        guard recommendations.isEmpty else { return } // Load once
        
        isLoading = true
        error = nil
        
        do {
            // 1. Fetch all active catalogs from Supabase
            let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                .from("catalogs")
                .select()
                .eq("status", value: "Active")
                .execute()
                .value
            
            // 2. Build ClientEntity with purchase history
            let purchases = PurchaseHistoryService.shared.fetchPurchases(clientId: client.id)
            let productIds = purchases.compactMap { $0.productId }
            
            let clientEntity = ClientEntity(
                id: client.id,
                name: client.name,
                email: client.email ?? "",
                phone: client.phone,
                dob: client.dob,
                tier: client.tier.rawValue,
                productsPurchased: productIds,
                createdAt: client.createdAt ?? Date(),
                updatedAt: Date(),
                maritalStatus: client.maritalStatus,
                dateOfAnniversary: client.dateOfAnniversary
            )
            
            // 3. Get Recommendations
            let engine = RecommendationEngine.shared
            let results = await engine.suggestProducts(for: clientEntity, catalog: catalogs, limit: 10)
            
            // 4. Generate Insight
            let generatedInsight: String
            if #available(iOS 18.0, *) {
                generatedInsight = await engine.generatePersonalizedInsight(client: clientEntity, recommendations: results) ?? "Curated picks based on their profile."
            } else {
                generatedInsight = "Curated picks based on their profile."
            }
            
            self.recommendations = results
            self.insight = generatedInsight
            self.isLoading = false
            
        } catch {
            self.error = error.localizedDescription
            self.isLoading = false
        }
    }
}
