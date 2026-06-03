import Foundation

struct PricingCampaign: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var region: String
    var discountPercentage: Double
    var startDate: Date
    var endDate: Date
    var status: CampaignStatus
    var affectedCategories: [String]
    
    enum CampaignStatus: String, Codable, CaseIterable {
        case draft = "Draft"
        case scheduled = "Scheduled"
        case active = "Active"
        case completed = "Completed"
    }
    
    // For demo/UI
    static let mockData: [PricingCampaign] = [
        PricingCampaign(id: UUID(), title: "Diwali Luxury Festival", region: "India", discountPercentage: 15.0, startDate: Date().addingTimeInterval(86400 * 5), endDate: Date().addingTimeInterval(86400 * 15), status: .scheduled, affectedCategories: ["Handbags", "Jewelry"]),
        PricingCampaign(id: UUID(), title: "Summer Sale Paris", region: "Europe", discountPercentage: 10.0, startDate: Date().addingTimeInterval(-86400 * 2), endDate: Date().addingTimeInterval(86400 * 5), status: .active, affectedCategories: ["Ready-to-Wear", "Shoes"]),
        PricingCampaign(id: UUID(), title: "Lunar New Year Exclusives", region: "APAC", discountPercentage: 12.0, startDate: Date().addingTimeInterval(-86400 * 30), endDate: Date().addingTimeInterval(-86400 * 10), status: .completed, affectedCategories: ["Accessories", "Leather Goods"])
    ]
}
