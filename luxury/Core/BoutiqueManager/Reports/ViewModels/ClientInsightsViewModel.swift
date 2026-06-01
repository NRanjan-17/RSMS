//
//  ClientInsightsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Supabase

@Observable
final class ClientInsightsViewModel {
    var totalClients: Int = 0
    var avgLTV: String = "\(CurrencyManager.shared.symbol)0"
    var tierBreakdown: [TierMetric] = []
    
    var isLoading = false
    
    func fetchData() {
        isLoading = true
        Task {
            do {
                let client = SupabaseManager.shared.client
                let clients: [ClientEntity] = try await client.from("client").select().execute().value
                let txs: [SATransactionEntity] = try await client.from("transaction").select().execute().value
                
                var uhnwCount = 0
                var vipCount = 0
                var standardCount = 0
                
                var uhnwRevenue = 0.0
                var vipRevenue = 0.0
                var standardRevenue = 0.0
                
                for c in clients {
                    let clientTxs = txs.filter { $0.clientId == c.id }
                    let clientTotal = clientTxs.reduce(0.0) { $0 + $1.transactionAmount }
                    
                    let tierString = (c.tier ?? "Standard").lowercased()
                    if tierString.contains("uhnw") {
                        uhnwCount += 1
                        uhnwRevenue += clientTotal
                    } else if tierString.contains("vip") {
                        vipCount += 1
                        vipRevenue += clientTotal
                    } else {
                        standardCount += 1
                        standardRevenue += clientTotal
                    }
                }
                
                let totalClients = clients.count
                let overallRevenue = txs.reduce(0.0) { $0 + $1.transactionAmount }
                let avg = totalClients > 0 ? overallRevenue / Double(totalClients) : 0.0
                
                let newTierBreakdown = [
                    TierMetric(tier: "UHNW", count: uhnwCount, revenue: CurrencyManager.shared.format(amount: uhnwRevenue)),
                    TierMetric(tier: "VIP", count: vipCount, revenue: CurrencyManager.shared.format(amount: vipRevenue)),
                    TierMetric(tier: "Standard", count: standardCount, revenue: CurrencyManager.shared.format(amount: standardRevenue))
                ]
                
                await MainActor.run {
                    self.totalClients = totalClients
                    self.avgLTV = CurrencyManager.shared.format(amount: avg)
                    self.tierBreakdown = newTierBreakdown
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch client insights: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
