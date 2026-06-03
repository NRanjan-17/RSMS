import Foundation
import NaturalLanguage
import Vision
#if canImport(LanguageModel)
import LanguageModel
#endif

/// Main engine responsible for scoring and recommending products based on user profile and history.
actor RecommendationEngine {
    static let shared = RecommendationEngine()
    
    // Using NLEmbedding for text vectorization
    private let sentenceEmbedding: NLEmbedding?
    
    private init() {
        // Initialize english sentence embedding model
        self.sentenceEmbedding = NLEmbedding.sentenceEmbedding(for: .english)
    }
    
    /// Suggests products for a specific client based on their purchase history, budget, and metadata.
    ///
    /// - Parameters:
    ///   - client: The client to recommend for.
    ///   - catalog: The full list of base catalog entities.
    ///   - availableStock: Dictionary mapping Catalog UUID to available stock count in the CURRENT boutique.
    ///   - limit: Maximum number of recommendations to return.
    /// - Returns: An array of recommended `CatalogEntity` sorted by Relevance Score descending.
    func suggestProducts(for client: ClientEntity, catalog: [CatalogEntity], availableStock: [UUID: Int], limit: Int = 10) async -> [CatalogEntity] {
        let activeCatalog = catalog.filter { item in
            let stock = availableStock[item.id] ?? 0
            return item.status == .active && stock > 0
        }
        guard !activeCatalog.isEmpty else { return [] }
        
        let purchasedProductIds = client.productsPurchased ?? []
        let purchasedItems = catalog.filter { purchasedProductIds.contains($0.id) }
        
        // FACTOR A: PURCHASE HISTORY (Client "Taste Centroid")
        var purchasedTextVectors: [[Float]] = []
        var purchasedVisualVectors: [[Float]] = []
        
        for item in purchasedItems {
            if let tVec = await getOrComputeTextEmbedding(for: item) {
                purchasedTextVectors.append(tVec)
            }
            if let vVec = await getOrComputeVisualEmbedding(for: item) {
                purchasedVisualVectors.append(vVec)
            }
        }
        
        let tasteTextCentroid = await MathUtilities.average(of: purchasedTextVectors)
        let tasteVisualCentroid = await MathUtilities.average(of: purchasedVisualVectors)
        
        let averagePurchaseAmount = calculateAveragePurchaseAmount(purchasedItems)
        
        var scoredItems: [(item: CatalogEntity, score: Float)] = []
        
        for item in activeCatalog {
            // Do not recommend items they already bought
            if purchasedProductIds.contains(item.id) { continue }
            
            var score: Float = 0
            
            // FACTOR B: SIMILAR PRODUCTS (Vector Distance)
            var textSimilarity: Float = 0
            var visualSimilarity: Float = 0
            
            if let tCentroid = tasteTextCentroid, let itemTVec = await getOrComputeTextEmbedding(for: item) {
                textSimilarity = await MathUtilities.cosineSimilarity(tCentroid, itemTVec)
            }
            
            if let vCentroid = tasteVisualCentroid, let itemVVec = await getOrComputeVisualEmbedding(for: item) {
                visualSimilarity = await MathUtilities.cosineSimilarity(vCentroid, itemVVec)
            }
            
            // If the user has no past purchases, default to a neutral zero score for similarity,
            // but the other factors (Budget, VIP, Events) might still rank them.
            
            // Weighting: 60% Visual, 40% Textual.
            // Baseline of 1.0 to ensure multipliers/penalties work correctly even on cold-starts.
            let similarityScore: Float = (visualSimilarity * 0.6) + (textSimilarity * 0.4)
            score = similarityScore + 1.0
            
            // FACTOR C: PRICE TIERING & BUDGET
            if let avgAmt = averagePurchaseAmount, avgAmt > 0 {
                let priceRatio = Float(item.amount / avgAmt)
                var penalty: Float = 0
                
                // Penalize drastically higher or lower prices to ensure realistic cross-selling
                if priceRatio > 2.0 {
                    penalty = (priceRatio - 2.0) * 0.1
                } else if priceRatio < 0.3 {
                    penalty = (0.3 - priceRatio) * 0.1
                }
                
                // FACTOR D: CLIENT METADATA (Rule-Based Boosts) - VIP Tier
                if client.tier == "VIP", penalty > 0, priceRatio > 2.0 {
                    // Reduce the high-price penalty for VIPs to allow luxury items to surface
                    penalty *= 0.3
                }
                
                score -= penalty
            }
            
            // FACTOR D: Events Boost
            if isEventWithin30Days(dob: client.dob, anniversary: client.dateOfAnniversary) {
                if item.category == .jewelry || item.category == .watches {
                    score += 0.2 // Apply additive boost to avoid issues with negative scores
                }
            }
            
            // FACTOR E: Cross-Category Discovery
            // Prevent the "filter bubble" (suggesting watches to people who just bought watches)
            let purchasedCategories = Set(purchasedItems.map { $0.category })
            if purchasedCategories.contains(item.category) {
                score -= 0.15 // Gentle penalty to heavily owned categories
            } else {
                score += 0.15 // Boost categories they haven't explored yet
            }
            
            scoredItems.append((item: item, score: score))
        }
        
        // Sort descending by relevance score
        let recommended = scoredItems.sorted { $0.score > $1.score }.prefix(limit).map { $0.item }
        return recommended
    }
    
    // MARK: - Item-to-Item Recommendation
    
    /// Suggests complementary products (Item-to-Item) for cross-selling.
    func suggestRelatedProducts(for targetItem: CatalogEntity, catalog: [CatalogEntity], availableStock: [UUID: Int], limit: Int = 3) async -> [CatalogEntity] {
        let activeCatalog = catalog.filter { item in
            let stock = availableStock[item.id] ?? 0
            return item.status == .active && stock > 0 && item.id != targetItem.id
        }
        guard !activeCatalog.isEmpty else { return [] }
        
        let targetTextVec = await getOrComputeTextEmbedding(for: targetItem)
        let targetVisualVec = await getOrComputeVisualEmbedding(for: targetItem)
        
        var scoredItems: [(item: CatalogEntity, score: Float)] = []
        
        for item in activeCatalog {
            var textSimilarity: Float = 0
            var visualSimilarity: Float = 0
            
            if let targetTVec = targetTextVec, let itemTVec = await getOrComputeTextEmbedding(for: item) {
                textSimilarity = await MathUtilities.cosineSimilarity(targetTVec, itemTVec)
            }
            if let targetVVec = targetVisualVec, let itemVVec = await getOrComputeVisualEmbedding(for: item) {
                visualSimilarity = await MathUtilities.cosineSimilarity(targetVVec, itemVVec)
            }
            
            // Baseline 1.0
            var score = (visualSimilarity * 0.6) + (textSimilarity * 0.4) + 1.0
            
            // CROSS-SELL FACTOR:
            // "Often paired with" implies finding items that complement, not replace.
            // Heavily penalize items in the exact same category.
            if item.category == targetItem.category {
                score -= 1.0 // Strong penalty to avoid Bag with Bag
            } else {
                score += 0.3 // Boost other categories for true pairings
            }
            
            // PRICE ALIGNMENT FACTOR:
            // A pairing usually shouldn't be drastically more expensive than the anchor item.
            if targetItem.amount > 0 {
                let priceRatio = Float(item.amount / targetItem.amount)
                if priceRatio > 2.0 {
                    score -= (priceRatio - 2.0) * 0.1
                }
            }
            
            scoredItems.append((item: item, score: score))
        }
        
        return scoredItems.sorted { $0.score > $1.score }.prefix(limit).map { $0.item }
    }
    
    // MARK: - Embedding Generation
    
    private func getOrComputeTextEmbedding(for item: CatalogEntity) async -> [Float]? {
        if let cached = await VectorRegistry.shared.getTextEmbedding(for: item.id) {
            return cached
        }
        
        // Create semantic string
        let textToEmbed = "\(item.name) \(item.brand) \(item.category.rawValue) \(item.description)"
        guard let sentenceEmbedding = sentenceEmbedding else { return nil }
        
        if let vector = sentenceEmbedding.vector(for: textToEmbed) {
            let floatVector = vector.map { Float($0) }
            await VectorRegistry.shared.saveTextEmbedding(floatVector, for: item.id)
            return floatVector
        }
        
        return nil
    }
    
    private func getOrComputeVisualEmbedding(for item: CatalogEntity) async -> [Float]? {
        if let cached = await VectorRegistry.shared.getVisualEmbedding(for: item.id) {
            return cached
        }
        
        guard let _ = item.productImages?.first else {
            return nil
        }
        
        /*
         NOTE: REAL IMPLEMENTATION (Network Request & Vision extraction)
         This requires async image fetching which might be heavy. In a real app we would
         download/cache the image and perform VNGenerateImageFeaturePrintRequest:
         
         guard let url = URL(string: imageUrlStr), let data = try? Data(contentsOf: url), let cgImage = UIImage(data: data)?.cgImage else { return nil }
         
         return await withCheckedContinuation { continuation in
             let request = VNGenerateImageFeaturePrintRequest { request, error in
                 if let featurePrint = request.results?.first as? VNFeaturePrintObservation {
                     var outArray = [Float](repeating: 0, count: featurePrint.elementCount)
                     try? featurePrint.data.copyBytes(to: &outArray, count: featurePrint.elementCount * MemoryLayout<Float>.size)
                     Task {
                         await VectorRegistry.shared.saveVisualEmbedding(outArray, for: item.id)
                     }
                     continuation.resume(returning: outArray)
                 } else {
                     continuation.resume(returning: nil)
                 }
             }
             let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
             try? handler.perform([request])
         }
         */
        
        // MOCK: Generate a deterministic pseudo-random vector based on ID for demonstration
        // using the Accelerate framework's required dimensions (e.g., 512 or 2048 depending on Vision model)
        let vector = generateMockVector(for: item.id)
        await VectorRegistry.shared.saveVisualEmbedding(vector, for: item.id)
        return vector
    }
    
    // MARK: - Helpers
    
    private func calculateAveragePurchaseAmount(_ items: [CatalogEntity]) -> Double? {
        guard !items.isEmpty else { return nil }
        let sum = items.reduce(0) { $0 + $1.amount }
        return sum / Double(items.count)
    }
    
    private func isEventWithin30Days(dob: String?, anniversary: String?) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let now = Date()
        let calendar = Calendar.current
        
        for dateStr in [dob, anniversary].compactMap({ $0 }) {
            guard let date = formatter.date(from: dateStr) else { continue }
            
            // Extract month and day from the event date
            var components = calendar.dateComponents([.month, .day], from: date)
            components.year = calendar.component(.year, from: now)
            
            if let thisYearDate = calendar.date(from: components) {
                // Determine if it's within the next 30 days
                let diff = calendar.dateComponents([.day], from: now, to: thisYearDate).day ?? Int.max
                
                if diff >= 0 && diff <= 30 {
                    return true
                }
                
                // If the event already passed this year, check next year
                components.year! += 1
                if let nextYearDate = calendar.date(from: components) {
                    let nextDiff = calendar.dateComponents([.day], from: now, to: nextYearDate).day ?? Int.max
                    if nextDiff >= 0 && nextDiff <= 30 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func generateMockVector(for uuid: UUID) -> [Float] {
        var rng = SystemRandomNumberGenerator()
        return (0..<512).map { _ in Float.random(in: -1...1, using: &rng) }
    }
    
    // MARK: - Apple Intelligence / LanguageModel (iOS 18+)
    
    /// Generates a short personalized sentence for the client using iOS 18 Apple Intelligence APIs.
    ///
    /// - Parameters:
    ///   - client: The client for whom the recommendation is generated.
    ///   - recommendations: The list of top recommended products.
    /// - Returns: A localized, personalized String.
    @available(iOS 18.0, *)
    func generatePersonalizedInsight(client: ClientEntity, recommendations: [CatalogEntity]) async -> String? {
        // Stub implementation utilizing the native text generation API concept
        
        /*
         // Example of Native LanguageModel Usage in iOS 18+ (if LanguageModel is imported)
         let prompt = "Write a one sentence pitch for \(client.name), suggesting the \(recommendations.first?.name ?? "luxury product")."
         
         do {
             // Assuming NLContextualLanguageModel or similar API provided in iOS 18
             let model = try await NLContextualLanguageModel()
             let response = try await model.generateResponse(for: prompt)
             return response
         } catch {
             return fallbackInsight()
         }
         */
        
        guard let topItem = recommendations.first else {
            return "We have curated a selection of items matching your profile."
        }
        
        let categoryName = topItem.category.rawValue.lowercased()
        
        if client.tier == "VIP" {
            return "As an exclusive VIP, we curated these exceptional \(categoryName) specifically for your distinct taste, \(client.name)."
        } else {
            return "Based on your interest in \(categoryName), we curated this selection to complement your style."
        }
    }
}
