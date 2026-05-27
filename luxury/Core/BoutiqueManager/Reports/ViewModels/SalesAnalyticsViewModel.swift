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
    var todaySales: String = "\(CurrencyManager.shared.symbol)12,45,000"
    var todayTarget: String = "\(CurrencyManager.shared.symbol)15,00,000"
    var wtdSales: String = "\(CurrencyManager.shared.symbol)45,20,000"
    var mtdSales: String = "\(CurrencyManager.shared.symbol)1,85,00,000"
    
    var categories: [SalesCategory] = [
        SalesCategory(name: "Watches", revenue: "\(CurrencyManager.shared.symbol)85,00,000", percentage: 0.45),
        SalesCategory(name: "Jewelry", revenue: "\(CurrencyManager.shared.symbol)65,00,000", percentage: 0.35),
        SalesCategory(name: "Leather Goods", revenue: "\(CurrencyManager.shared.symbol)25,00,000", percentage: 0.15),
        SalesCategory(name: "Accessories", revenue: "\(CurrencyManager.shared.symbol)10,00,000", percentage: 0.05)
    ]
}
