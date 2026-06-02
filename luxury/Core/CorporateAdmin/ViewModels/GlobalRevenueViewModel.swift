import Foundation
import Observation
import Supabase

enum RevenueTimeframe: String, CaseIterable {
    case days = "Days"
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

@Observable
final class GlobalRevenueViewModel {
    var isLoading = false
    var errorMessage: String?
    
    var selectedTimeframe: RevenueTimeframe = .month
    
    var chartData: [RevenueData] = []
    var transactions: [OrderEntity] = []
    var totalRevenue: Double = 0.0
    
    private var allOrders: [OrderEntity] = []
    
    private let client = SupabaseManager.shared.client
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [OrderEntity] = try await client.from("order")
                .select()
                .order("dateOfPurchase", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                self.allOrders = fetched
                self.transactions = fetched
                self.totalRevenue = fetched.reduce(0) { $0 + $1.totalPrice }
                self.processChartData()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func setTimeframe(_ timeframe: RevenueTimeframe) {
        self.selectedTimeframe = timeframe
        self.processChartData()
    }
    
    private func processChartData() {
        let calendar = Calendar.current
        let now = Date()
        var grouped: [String: Double] = [:]
        
        // Filter orders based on timeframe and calculate grouped data
        switch selectedTimeframe {
        case .days:
            // Last 7 days
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE" // Mon, Tue, etc
            
            for i in (0..<7).reversed() {
                if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                    let label = dateFormatter.string(from: date)
                    grouped[label] = 0.0
                }
            }
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                if calendar.dateComponents([.day], from: date, to: now).day ?? 0 < 7 {
                    let label = dateFormatter.string(from: date)
                    grouped[label, default: 0.0] += tx.totalPrice
                }
            }
            
            chartData = grouped.map { RevenueData(month: $0.key, amount: $0.value) }
                // Sort by day of week relative to today
                .sorted {
                    let date1 = calendar.nextDate(after: now, matching: DateComponents(weekday: getWeekday(from: $0.month)), matchingPolicy: .nextTime, direction: .backward) ?? Date()
                    let date2 = calendar.nextDate(after: now, matching: DateComponents(weekday: getWeekday(from: $1.month)), matchingPolicy: .nextTime, direction: .backward) ?? Date()
                    return date1 < date2
                }
            
        case .week:
            // Last 4 weeks
            for i in (0..<4).reversed() {
                grouped["W\(4-i)"] = 0.0
            }
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                let daysAgo = calendar.dateComponents([.day], from: date, to: now).day ?? 0
                if daysAgo < 28 {
                    let weekIndex = 4 - (daysAgo / 7)
                    grouped["W\(weekIndex)", default: 0.0] += tx.totalPrice
                }
            }
            
            chartData = grouped.map { RevenueData(month: $0.key, amount: $0.value) }.sorted { $0.month < $1.month }
            
        case .month:
            // Last 12 months
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            for i in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                    let label = dateFormatter.string(from: date)
                    grouped[label] = 0.0
                }
            }
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                if calendar.dateComponents([.month], from: date, to: now).month ?? 0 < 12 {
                    let label = dateFormatter.string(from: date)
                    grouped[label, default: 0.0] += tx.totalPrice
                }
            }
            
            // Sort to chronological 12 months
            var sortedData: [RevenueData] = []
            for i in (0..<12).reversed() {
                if let date = calendar.date(byAdding: .month, value: -i, to: now) {
                    let label = dateFormatter.string(from: date)
                    let amount = grouped[label] ?? 0.0
                    sortedData.append(RevenueData(month: label, amount: amount))
                }
            }
            chartData = sortedData
            
        case .year:
            // Last 5 years
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            
            for i in (0..<5).reversed() {
                if let date = calendar.date(byAdding: .year, value: -i, to: now) {
                    let label = dateFormatter.string(from: date)
                    grouped[label] = 0.0
                }
            }
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                if calendar.dateComponents([.year], from: date, to: now).year ?? 0 < 5 {
                    let label = dateFormatter.string(from: date)
                    grouped[label, default: 0.0] += tx.totalPrice
                }
            }
            
            chartData = grouped.map { RevenueData(month: $0.key, amount: $0.value) }.sorted { $0.month < $1.month }
        }
    }
    
    private func getWeekday(from string: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        if let date = formatter.date(from: string) {
            return Calendar.current.component(.weekday, from: date)
        }
        return 1
    }
}
