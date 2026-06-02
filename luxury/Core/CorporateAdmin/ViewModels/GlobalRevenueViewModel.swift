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
    var todayRevenue: Double = 0.0
    
    private var allOrders: [OrderEntity] = []
    
    private let client = SupabaseManager.shared.client
    
    func fetchData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched: [OrderEntity] = try await client.from("order")
                .select()
                .order("date_of_purchase", ascending: false)
                .execute()
                .value
            
            await MainActor.run {
                self.allOrders = fetched
                self.transactions = fetched
                self.totalRevenue = fetched.reduce(0) { $0 + $1.totalPrice }
                
                let calendar = Calendar.current
                let startOfToday = calendar.startOfDay(for: Date())
                self.todayRevenue = fetched.filter { 
                    guard let date = $0.dateOfPurchase else { return false }
                    return date >= startOfToday
                }.reduce(0) { $0 + $1.totalPrice }
                
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
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday
        let now = Date()
        var grouped: [String: Double] = [:]
        
        // Filter orders based on timeframe and calculate grouped data
        switch selectedTimeframe {
        case .days:
            // Current Week starting from Monday
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE" // Mon, Tue, etc
            
            // Find start of the current week
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
            components.weekday = 2 // Monday
            guard let startOfWeek = calendar.date(from: components) else { return }
            
            var weekDays: [Date] = []
            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                    let label = dateFormatter.string(from: date)
                    grouped[label] = 0.0
                    weekDays.append(date)
                }
            }
            
            let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? now
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                if date >= startOfWeek && date < endOfWeek {
                    let label = dateFormatter.string(from: date)
                    grouped[label, default: 0.0] += tx.totalPrice
                }
            }
            
            chartData = weekDays.map { date in
                let label = dateFormatter.string(from: date)
                return RevenueData(month: label, amount: grouped[label] ?? 0.0)
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
            // Current Year (Jan-Dec)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) else { return }
            
            var months: [Date] = []
            for i in 0..<12 {
                if let date = calendar.date(byAdding: .month, value: i, to: startOfYear) {
                    let label = dateFormatter.string(from: date)
                    grouped[label] = 0.0
                    months.append(date)
                }
            }
            
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? now
            
            for tx in allOrders {
                guard let date = tx.dateOfPurchase else { continue }
                if date >= startOfYear && date < endOfYear {
                    let label = dateFormatter.string(from: date)
                    grouped[label, default: 0.0] += tx.totalPrice
                }
            }
            
            chartData = months.map { date in
                let label = dateFormatter.string(from: date)
                return RevenueData(month: label, amount: grouped[label] ?? 0.0)
            }
            
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
