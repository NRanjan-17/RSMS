//
//  GlobalAnalyticsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI
import Observation
import Supabase

@Observable
final class GlobalAnalyticsViewModel {
    var isLoading = false
    var errorMessage: String?
    
    var kpis: [GlobalKPI] = []
    
    var revenueChartData: [RevenueData] = []
    
    var boutiquePerformance: [CorporateBoutique] = []
    var sfsFulfillments: [PurchasedItemEntity] = []
    private var sfsPollingTask: Task<Void, Never>?
    
    private let client = SupabaseManager.shared.client
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            var boutiquesResponse: [CorporateBoutique] = []
            var staffResponse: [StaffModel] = []
            var catalogs: [CatalogEntity] = []
            var orders: [OrderEntity] = []
            
            do {
                boutiquesResponse = try await client.from("boutiques").select().eq("status", value: "approved").execute().value
            } catch {
                print("Boutiques fetch error: \(error)")
            }
            
            do {
                staffResponse = try await client.from("staff").select().execute().value
            } catch {
                print("Staff fetch error: \(error)")
            }
            
            do {
                catalogs = try await client.from("catalogs").select().execute().value
            } catch {
                print("Catalogs fetch error: \(error)")
            }
            
            do {
                orders = try await client.from("order").select().execute().value
            } catch {
                print("Order fetch error: \(error)")
            }
            
            // Calculate inventory value
            var totalInventoryValue = 0.0
            var stockDict: [UUID: Int] = [:]
            
            if let allUnits = try? await InventoryService.shared.fetchAllInventoryUnits() {
                for unit in allUnits where unit.status == .available {
                    stockDict[unit.catalogId, default: 0] += 1
                }
            }
            
            for item in catalogs {
                let totalStock = stockDict[item.id] ?? 0
                if totalStock > 0 {
                    totalInventoryValue += (item.amount * Double(totalStock))
                }
            }
            
            let now = Date()
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: now)
            let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now)!
            let sixtyDaysAgo = calendar.date(byAdding: .day, value: -60, to: now)!
            
            var totalRevenue = 0.0
            var todayRevenue = 0.0
            var yesterdayRevenue = 0.0
            var revenueByMonth: [String: Double] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            for tx in orders {
                totalRevenue += tx.totalPrice
                if let date = tx.dateOfPurchase {
                    let monthStr = dateFormatter.string(from: date)
                    revenueByMonth[monthStr, default: 0.0] += tx.totalPrice
                    
                    if date >= startOfToday {
                        todayRevenue += tx.totalPrice
                    } else if date >= startOfYesterday && date < startOfToday {
                        yesterdayRevenue += tx.totalPrice
                    }
                }
            }
            
            // Calculate revenue trend (day-over-day %)
            let revenueTrend: Double = yesterdayRevenue > 0
                ? ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100.0
                : (todayRevenue > 0 ? 100.0 : 0.0)
            
            // Calculate boutique trend (added in last 30 days vs previous 30 days)
            let recentBoutiques = boutiquesResponse.filter { $0.createdAt >= thirtyDaysAgo }.count
            let previousBoutiques = boutiquesResponse.filter { $0.createdAt >= sixtyDaysAgo && $0.createdAt < thirtyDaysAgo }.count
            let boutiqueTrend: Double = previousBoutiques > 0
                ? (Double(recentBoutiques - previousBoutiques) / Double(previousBoutiques)) * 100.0
                : (recentBoutiques > 0 ? 100.0 : 0.0)
            
            // Calculate staff trend (added in last 30 days vs previous 30 days)
            let recentStaff = staffResponse.filter { $0.createdAt >= thirtyDaysAgo }.count
            let previousStaff = staffResponse.filter { $0.createdAt >= sixtyDaysAgo && $0.createdAt < thirtyDaysAgo }.count
            let staffTrend: Double = previousStaff > 0
                ? (Double(recentStaff - previousStaff) / Double(previousStaff)) * 100.0
                : (recentStaff > 0 ? 100.0 : 0.0)
            
            // Calculate inventory trend (recent catalog value vs older)
            let recentInventoryItems = catalogs.filter {
                let totalStock = stockDict[$0.id] ?? 0
                return totalStock > 0
            }
            let totalItems = catalogs.count
            let inventoryTrend: Double = totalItems > 0
                ? (Double(recentInventoryItems.count) / Double(totalItems)) * 100.0 - 50.0
                : 0.0
            
            // Format daily revenue chart data for dashboard glimpse
            var dailyChartData: [RevenueData] = []
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "EEE" // Mon, Tue...
            
            for i in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let label = dayFormatter.string(from: date)
                    let startOfDay = calendar.startOfDay(for: date)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    
                    let dailyTotal = orders.filter { tx in
                        guard let txDate = tx.dateOfPurchase else { return false }
                        return txDate >= startOfDay && txDate < endOfDay
                    }.reduce(0.0) { $0 + $1.totalPrice }
                    
                    dailyChartData.append(RevenueData(month: label, amount: dailyTotal))
                }
            }
            
            let newKpis = [
                GlobalKPI(label: "Global Revenue", type: .currency(totalRevenue), trend: revenueTrend, icon: "chart.line.uptrend.xyaxis"),
                GlobalKPI(label: "Active Boutiques", type: .string("\(boutiquesResponse.count)"), trend: 0.0, icon: "building.2.fill"),
                GlobalKPI(label: "Total Staff", type: .string("\(staffResponse.count)"), trend: 0.0, icon: "person.3.fill"),
                GlobalKPI(label: "Inventory Value", type: .currency(totalInventoryValue), trend: inventoryTrend, icon: "shippingbox.fill")
            ]
            
            await MainActor.run {
                self.boutiquePerformance = boutiquesResponse
                self.kpis = newKpis
                self.revenueChartData = dailyChartData
                self.isLoading = false
            }
        }
    }

    func fetchSFSFulfillments() async {
        do {
            let items: [PurchasedItemEntity] = try await client
                .from("purchased_items")
                .select()
                .execute()
                .value
            
            let products: [CatalogEntity] = try await client
                .from("catalogs")
                .select()
                .execute()
                .value
            
            var resolved: [PurchasedItemEntity] = []
            for var item in items {
                if let product = products.first(where: { $0.id == item.productId }) {
                    item.productName = product.name
                    item.productBrand = product.brand
                    item.productSku = product.catalogId
                }
                resolved.append(item)
            }
            
            let sorted = resolved.sorted(by: { $0.reservedDate > $1.reservedDate })
            
            await MainActor.run {
                self.sfsFulfillments = sorted
            }
        } catch {
            print("Failed to fetch SFS fulfillments: \(error)")
        }
    }

    // TODO: upgrade to WebSocket/SSE
    func startFulfillmentPolling() {
        sfsPollingTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                await self?.fetchSFSFulfillments()
                try? await Task.sleep(for: .seconds(5))
            }
        }
    }

    func stopFulfillmentPolling() {
        sfsPollingTask?.cancel()
        sfsPollingTask = nil
    }
}
