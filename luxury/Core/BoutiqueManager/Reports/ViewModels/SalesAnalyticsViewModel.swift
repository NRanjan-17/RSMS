//
//  SalesAnalyticsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class SalesAnalyticsViewModel {
    var todaySales: String = "₹12,45,000"
    var todayTarget: String = "₹15,00,000"
    var wtdSales: String = "₹45,20,000"
    var mtdSales: String = "₹1,85,00,000"
    
    var categories: [SalesCategory] = [
        SalesCategory(name: "Watches", revenue: "₹85,00,000", percentage: 0.45),
        SalesCategory(name: "Jewelry", revenue: "₹65,00,000", percentage: 0.35),
        SalesCategory(name: "Leather Goods", revenue: "₹25,00,000", percentage: 0.15),
        SalesCategory(name: "Accessories", revenue: "₹10,00,000", percentage: 0.05)
    ]
}
