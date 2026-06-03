import Foundation
import SwiftUI

@Observable
final class PricingCampaignViewModel {
    var campaigns: [PricingCampaign] = PricingCampaign.mockData
    
    func addCampaign(title: String, region: String, discountPercentage: Double, startDate: Date, endDate: Date, categories: [String]) {
        let newCampaign = PricingCampaign(
            id: UUID(),
            title: title,
            region: region,
            discountPercentage: discountPercentage,
            startDate: startDate,
            endDate: endDate,
            status: .scheduled,
            affectedCategories: categories
        )
        campaigns.append(newCampaign)
    }
    
    func toggleStatus(for campaign: PricingCampaign) {
        if let index = campaigns.firstIndex(where: { $0.id == campaign.id }) {
            var updated = campaigns[index]
            if updated.status == .active {
                updated.status = .completed
            } else if updated.status == .scheduled {
                updated.status = .active
            }
            campaigns[index] = updated
        }
    }
    
    func badgeStatus(for status: PricingCampaign.CampaignStatus) -> BadgeStatus {
        switch status {
        case .draft: return .neutral
        case .scheduled: return .pending
        case .active: return .success
        case .completed: return .neutral
        }
    }
}
