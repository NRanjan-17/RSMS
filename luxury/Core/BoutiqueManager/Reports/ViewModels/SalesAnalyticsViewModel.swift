//
//  SalesAnalyticsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class SalesAnalyticsViewModel {
    var todaySales: String = "\(CurrencyManager.shared.symbol)0"
    var todayTarget: String = "\(CurrencyManager.shared.symbol)0"
    var wtdSales: String = "\(CurrencyManager.shared.symbol)0"
    var mtdSales: String = "\(CurrencyManager.shared.symbol)0"
    
    var categories: [SalesCategory] = []
    var isLoading = false
    
    func fetchData() async {
        await MainActor.run { isLoading = true }
        do {
            guard let profileTuple = try? await ProfileService().fetchCurrentProfile(),
                  let staff = profileTuple.1 as? StaffModel,
                  let bId = staff.boutiqueId else {
                await MainActor.run { isLoading = false }
                return
            }
            
            // 1. Fetch all transactions for this boutique
            let txs: [SATransactionEntity] = try await SupabaseManager.shared.client
                .from("transaction")
                .select()
                .eq("boutique_id", value: bId)
                .execute()
                .value
                
            // 2. Fetch boutique daily target
            struct BoutiqueTarget: Codable {
                let dailySalesTarget: Double?
                enum CodingKeys: String, CodingKey {
                    case dailySalesTarget = "daily_sales_target"
                }
            }
            let boutiqueTargets: [BoutiqueTarget] = (try? await SupabaseManager.shared.client
                .from("boutiques")
                .select("daily_sales_target")
                .eq("id", value: bId)
                .execute()
                .value) ?? []
            let bTarget = boutiqueTargets.first?.dailySalesTarget ?? 200000.0
                
            // 3. Calculate time-based revenue (Today, WTD, MTD)
            let now = Date()
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current
            
            let startOfToday = calendar.startOfDay(for: now)
            
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekday = calendar.firstWeekday
            let startOfWeek = calendar.date(from: components) ?? startOfToday
            
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? startOfToday
            
            var tSales = 0.0
            var wSales = 0.0
            var mSales = 0.0
            
            for tx in txs {
                guard let d = tx.dateOfTransaction else { continue }
                if d >= startOfToday {
                    tSales += tx.transactionAmount
                }
                if d >= startOfWeek {
                    wSales += tx.transactionAmount
                }
                if d >= startOfMonth {
                    mSales += tx.transactionAmount
                }
            }
            
            // 4. Fetch purchased_items for this boutique to get category-level breakdown
            struct PurchasedItemMin: Codable {
                let productId: UUID
                enum CodingKeys: String, CodingKey {
                    case productId = "product_id"
                }
            }
            let purchasedItems: [PurchasedItemMin] = (try? await SupabaseManager.shared.client
                .from("purchased_items")
                .select("product_id")
                .eq("boutique_id", value: bId)
                .execute()
                .value) ?? []
            
            // 5. Fetch catalogs to map product_id -> category + amount
            let catalogs: [CatalogEntity] = (try? await SupabaseManager.shared.client
                .from("catalogs")
                .select()
                .execute()
                .value) ?? []
            let catalogDict = Dictionary(uniqueKeysWithValues: catalogs.map { ($0.id, $0) })
            
            // 6. Calculate revenue per category from purchased items
            var categoryRevenue: [String: Double] = [:]
            for item in purchasedItems {
                if let catalog = catalogDict[item.productId] {
                    let catName = catalog.category.rawValue
                    categoryRevenue[catName, default: 0] += catalog.amount
                }
            }
            
            // 7. Build category list sorted by revenue (descending)
            let totalCatRevenue = categoryRevenue.values.reduce(0, +)
            var newCategories: [SalesCategory] = []
            
            if totalCatRevenue > 0 {
                // Real data from purchased_items
                let sorted = categoryRevenue.sorted { $0.value > $1.value }
                for (name, revenue) in sorted {
                    let pct = revenue / totalCatRevenue
                    newCategories.append(SalesCategory(
                        name: name,
                        revenue: CurrencyManager.shared.format(amount: revenue),
                        percentage: pct
                    ))
                }
            } else {
                // Fallback: use all CatalogCategory cases with zero
                for cat in CatalogCategory.allCases {
                    newCategories.append(SalesCategory(
                        name: cat.rawValue,
                        revenue: CurrencyManager.shared.format(amount: 0),
                        percentage: 0
                    ))
                }
            }
            
            await MainActor.run {
                self.todaySales = CurrencyManager.shared.format(amount: tSales)
                self.wtdSales = CurrencyManager.shared.format(amount: wSales)
                self.mtdSales = CurrencyManager.shared.format(amount: mSales)
                self.todayTarget = CurrencyManager.shared.format(amount: staff.dailySalesTarget ?? bTarget)
                self.categories = newCategories
                self.isLoading = false
            }
        } catch {
            print("Failed to fetch SalesAnalytics: \(error)")
            await MainActor.run { self.isLoading = false }
        }
    }
}
