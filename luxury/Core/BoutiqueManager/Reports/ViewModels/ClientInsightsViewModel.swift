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
                guard let profileTuple = try? await ProfileService().fetchCurrentProfile(),
                      let staff = profileTuple.1 as? StaffModel,
                      let bId = staff.boutiqueId else {
                    await MainActor.run { isLoading = false }
                    return
                }
                
                let client = SupabaseManager.shared.client
                let clients: [ClientEntity] = try await client.from("client").select().execute().value
                let txs: [SATransactionEntity] = try await client.from("transaction")
                    .select()
                    .eq("boutique_id", value: bId)
                    .execute()
                    .value
                
                let boutiqueClientIds = Set(txs.compactMap { $0.clientId })
                let boutiqueClients = clients.filter { boutiqueClientIds.contains($0.id) }
                
                var uhnwCount = 0
                var vipCount = 0
                var standardCount = 0
                
                var uhnwRevenue = 0.0
                var vipRevenue = 0.0
                var standardRevenue = 0.0
                
                for c in boutiqueClients {
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
                
                let totalClientsCount = boutiqueClients.count
                let overallRevenue = txs.reduce(0.0) { $0 + $1.transactionAmount }
                let avg = totalClientsCount > 0 ? overallRevenue / Double(totalClientsCount) : 0.0
                
                let newTierBreakdown = [
                    TierMetric(tier: "UHNW", count: uhnwCount, revenue: CurrencyManager.shared.format(amount: uhnwRevenue)),
                    TierMetric(tier: "VIP", count: vipCount, revenue: CurrencyManager.shared.format(amount: vipRevenue)),
                    TierMetric(tier: "Standard", count: standardCount, revenue: CurrencyManager.shared.format(amount: standardRevenue))
                ]
                
                await MainActor.run {
                    self.totalClients = totalClientsCount
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
