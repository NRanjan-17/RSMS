//
//  StaffPerformanceViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class StaffPerformanceViewModel {
    var staffMetrics: [StaffMetric] = [
        StaffMetric(name: "Aman Gupta", commission: "\(CurrencyManager.shared.symbol)18,375", conversion: (0.32).formatted(.percent), interactions: 45),
        StaffMetric(name: "Priya R.", commission: "\(CurrencyManager.shared.symbol)12,450", conversion: (0.28).formatted(.percent), interactions: 38),
        StaffMetric(name: "Suresh V.", commission: "\(CurrencyManager.shared.symbol)9,200", conversion: (0.24).formatted(.percent), interactions: 42),
        StaffMetric(name: "Ananya M.", commission: "\(CurrencyManager.shared.symbol)0", conversion: (0.0).formatted(.percent), interactions: 12)
    ]
}
