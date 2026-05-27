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
        StaffMetric(name: "Aman Gupta", commission: "\(CurrencyManager.shared.symbol)18,375", conversion: "32%", interactions: 45),
        StaffMetric(name: "Priya R.", commission: "\(CurrencyManager.shared.symbol)12,450", conversion: "28%", interactions: 38),
        StaffMetric(name: "Suresh V.", commission: "\(CurrencyManager.shared.symbol)9,200", conversion: "24%", interactions: 42),
        StaffMetric(name: "Ananya M.", commission: "\(CurrencyManager.shared.symbol)0", conversion: "0%", interactions: 12)
    ]
}
