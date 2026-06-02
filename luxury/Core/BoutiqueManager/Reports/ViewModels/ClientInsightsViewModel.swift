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
    var avgLTV: String = "\(CurrencyManager.shared.symbol)8,45,000"
    
    var tierBreakdown: [TierMetric] = [
        TierMetric(tier: "High Networth", count: 12, revenue: "\(CurrencyManager.shared.symbol)4,50,00,000"),
        TierMetric(tier: "VIP", count: 42, revenue: "\(CurrencyManager.shared.symbol)2,10,00,000"),
        TierMetric(tier: "Standard", count: 70, revenue: "\(CurrencyManager.shared.symbol)85,00,000")
    ]
}
