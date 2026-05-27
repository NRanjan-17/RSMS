//
//  StorePerformanceViewModel.swift
//  luxury
//
//  Created by Kaushiki Rai on 26/05/26.
//

//
//  StorePerformanceViewModel.swift
//  luxury
//
//  Created by Kaushiki Rai on 26/05/26.
//

import Foundation
import Observation

struct BoutiquePerformance: Identifiable, Hashable {
    static func == (lhs: BoutiquePerformance, rhs: BoutiquePerformance) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: UUID
    let boutiqueName: String
    let city: String
    let totalSales: Double
    let salesTarget: Double
    let totalWalkIns: Int
    let convertedCustomers: Int
    let totalTransactions: Int
    let associates: [AssociatePerformance]

    var achievementPct: Double   { salesTarget > 0 ? (totalSales / salesTarget) * 100 : 0 }
    var conversionRate: Double   { totalWalkIns > 0 ? (Double(convertedCustomers) / Double(totalWalkIns)) * 100 : 0 }
    var atv: Double              { totalTransactions > 0 ? totalSales / Double(totalTransactions) : 0 }
    var isUnderperforming: Bool  { achievementPct < 80 }
}

struct AssociatePerformance: Identifiable, Hashable {
    static func == (lhs: AssociatePerformance, rhs: AssociatePerformance) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: UUID
    let name: String
    let totalSales: Double
    let transactions: Int
    let walkIns: Int
    let converted: Int

    var conversionRate: Double { walkIns > 0 ? (Double(converted) / Double(walkIns)) * 100 : 0 }
    var abv: Double            { transactions > 0 ? totalSales / Double(transactions) : 0 }
}

@Observable
final class StorePerformanceViewModel {
    var boutiques: [BoutiquePerformance] = []
    var isLoading = false

    func fetchData() {
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            await MainActor.run {
                self.boutiques = Self.mockData()
                self.isLoading = false
            }
        }
    }

    private static func mockData() -> [BoutiquePerformance] {
        [
            BoutiquePerformance(
                id: UUID(), boutiqueName: "Maison Mumbai", city: "Mumbai",
                totalSales: 4_20_000, salesTarget: 5_00_000,
                totalWalkIns: 120, convertedCustomers: 46,
                totalTransactions: 46,
                associates: [
                    AssociatePerformance(id: UUID(), name: "Arjun Singh",   totalSales: 2_10_000, transactions: 23, walkIns: 60, converted: 26),
                    AssociatePerformance(id: UUID(), name: "Priya Sharma",  totalSales: 1_10_000, transactions: 13, walkIns: 34, converted: 12),
                    AssociatePerformance(id: UUID(), name: "Rahul Mehta",   totalSales: 1_00_000, transactions: 10, walkIns: 26, converted: 8)
                ]
            ),
            BoutiquePerformance(
                id: UUID(), boutiqueName: "Maison Delhi", city: "New Delhi",
                totalSales: 6_80_000, salesTarget: 7_00_000,
                totalWalkIns: 95, convertedCustomers: 52,
                totalTransactions: 52,
                associates: [
                    AssociatePerformance(id: UUID(), name: "Neha Kapoor",   totalSales: 3_40_000, transactions: 26, walkIns: 48, converted: 28),
                    AssociatePerformance(id: UUID(), name: "Vikram Nair",   totalSales: 2_20_000, transactions: 16, walkIns: 30, converted: 16),
                    AssociatePerformance(id: UUID(), name: "Aditi Rao",     totalSales: 1_20_000, transactions: 10, walkIns: 17, converted: 8)
                ]
            ),
            BoutiquePerformance(
                id: UUID(), boutiqueName: "Maison Bangalore", city: "Bengaluru",
                totalSales: 2_10_000, salesTarget: 4_50_000,
                totalWalkIns: 80, convertedCustomers: 22,
                totalTransactions: 22,
                associates: [
                    AssociatePerformance(id: UUID(), name: "Karan Joshi",   totalSales: 1_20_000, transactions: 12, walkIns: 44, converted: 12),
                    AssociatePerformance(id: UUID(), name: "Sneha Pillai",  totalSales:   90_000, transactions: 10, walkIns: 36, converted: 10)
                ]
            ),
            BoutiquePerformance(
                id: UUID(), boutiqueName: "Maison Chennai", city: "Chennai",
                totalSales: 5_10_000, salesTarget: 5_00_000,
                totalWalkIns: 110, convertedCustomers: 64,
                totalTransactions: 64,
                associates: [
                    AssociatePerformance(id: UUID(), name: "Divya Menon",   totalSales: 2_60_000, transactions: 32, walkIns: 55, converted: 34),
                    AssociatePerformance(id: UUID(), name: "Arun Balaji",   totalSales: 2_50_000, transactions: 32, walkIns: 55, converted: 30)
                ]
            )
        ]
    }
}
