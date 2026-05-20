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
    
    var kpis: [GlobalKPI] = [
        GlobalKPI(label: "Global Revenue", value: "₹0 Cr", trend: 0.0, icon: "indianrupeesign.circle.fill"),
        GlobalKPI(label: "Active Boutiques", value: "14", trend: 0.0, icon: "building.2.fill"),
        GlobalKPI(label: "Total Staff", value: "242", trend: 4.2, icon: "person.3.fill"),
        GlobalKPI(label: "Global Shrink", value: "0.82%", trend: -2.1, icon: "exclamationmark.triangle.fill")
    ]
    
    var revenueChartData: [RevenueData] = [
        RevenueData(month: "Jan", amount: 18.2),
        RevenueData(month: "Feb", amount: 21.5),
        RevenueData(month: "Mar", amount: 24.8),
        RevenueData(month: "Apr", amount: 22.1),
        RevenueData(month: "May", amount: 26.4)
    ]
    
    var boutiquePerformance: [CorporateBoutique] = []
    
    private let client = SupabaseManager.shared.client
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response: [CorporateBoutique] = try await client.from("boutiques").select().eq("status", value: "approved").execute().value
                
                await MainActor.run {
                    self.boutiquePerformance = response
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch analytics: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}
