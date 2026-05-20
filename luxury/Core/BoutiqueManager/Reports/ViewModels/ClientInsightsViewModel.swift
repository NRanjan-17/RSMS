//
//  ClientInsightsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ClientInsightsViewModel {
    var totalVIPs: Int = 124
    var avgLTV: String = "₹8,45,000"
    
    var tierBreakdown: [TierMetric] = [
        TierMetric(tier: "UHNW", count: 12, revenue: "₹4,50,00,000"),
        TierMetric(tier: "VIP", count: 42, revenue: "₹2,10,00,000"),
        TierMetric(tier: "Standard", count: 70, revenue: "₹85,00,000")
    ]
}
