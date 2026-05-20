//
//  ShrinkReportViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ShrinkReportViewModel {
    var totalShrinkValue: String = "₹1,45,000"
    var accuracy: String = "98.2%"
    
    var recentWriteOffs: [RSMSVarianceItem] = [
        RSMSVarianceItem(name: "Diamond Ring 18K Gold", expected: 5, actual: 4, reason: "Missing / Under Investigation"),
        RSMSVarianceItem(name: "Men's Wallet Brown", expected: 8, actual: 7, reason: "Damaged / Scrapped")
    ]
}
