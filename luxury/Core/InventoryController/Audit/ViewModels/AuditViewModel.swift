//
//  AuditViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class AuditViewModel {
    var scheduledCounts: [RSMSCycleCount] = []
    var recentAudits: [RSMSCycleCount] = []
    
    init() {
        refreshData()
    }
    
    func refreshData() {
        var sessions = AuditPersistence.shared.loadAllSessions()
        
        var migrated = false
        for i in 0..<sessions.count {
            if sessions[i].title == "Monthly Full Audit" {
                var updated = sessions[i]
                updated.title = "Full Audit"
                AuditPersistence.shared.saveSession(updated)
                migrated = true
            }
        }
        if migrated {
            sessions = AuditPersistence.shared.loadAllSessions()
        }
        
        if sessions.isEmpty {
            let monthly = AuditSession(
                id: UUID(uuidString: "7f4c0a52-9b22-4a0b-8df7-ee6a17b01931")!,
                title: "Full Audit",
                date: "31 May 2026",
                scope: "Full Store",
                status: "Scheduled",
                badgeStatus: .neutral,
                storeName: "",
                controllerName: "",
                isSubmitted: false,
                expectedItems: []
            )
            
            let categoryReport = VarianceReport(
                id: UUID(uuidString: "8a4c0a52-9b22-4a0b-8df7-ee6a17b01932")!,
                boutiqueName: "Main Boutique",
                date: Date(),
                controllerName: "Staff Member",
                items: [
                    VarianceReportItem(id: UUID(), productName: "Leather Tote L", sku: "LT-8820", expectedQty: 10, countedQty: 10, variance: 0, isArchivedProduct: false),
                    VarianceReportItem(id: UUID(), productName: "Slim Wallet", sku: "SW-1020", expectedQty: 15, countedQty: 14, variance: -1, isArchivedProduct: false)
                ]
            )
            let category = AuditSession(
                id: UUID(uuidString: "8a4c0a52-9b22-4a0b-8df7-ee6a17b01932")!,
                title: "Category Audit",
                date: "12 May 2026",
                scope: "Leather Goods",
                status: "Signed Off",
                badgeStatus: .success,
                storeName: "Main Boutique",
                controllerName: "Staff Member",
                isSubmitted: true,
                expectedItems: [],
                varianceReport: categoryReport
            )
            
            let weeklyReport = VarianceReport(
                id: UUID(uuidString: "9b4c0a52-9b22-4a0b-8df7-ee6a17b01933")!,
                boutiqueName: "Main Boutique",
                date: Date(),
                controllerName: "Staff Member",
                items: [
                    VarianceReportItem(id: UUID(), productName: "Belt Classic Brown", sku: "BC-3301", expectedQty: 25, countedQty: 25, variance: 0, isArchivedProduct: false),
                    VarianceReportItem(id: UUID(), productName: "Card Holder", sku: "CH-4402", expectedQty: 30, countedQty: 30, variance: 0, isArchivedProduct: false)
                ]
            )
            let weekly = AuditSession(
                id: UUID(uuidString: "9b4c0a52-9b22-4a0b-8df7-ee6a17b01933")!,
                title: "Weekly Quick Scan",
                date: "08 May 2026",
                scope: "Zone B",
                status: "Signed Off",
                badgeStatus: .success,
                storeName: "Main Boutique",
                controllerName: "Staff Member",
                isSubmitted: true,
                expectedItems: [],
                varianceReport: weeklyReport
            )
            
            AuditPersistence.shared.saveSession(monthly)
            AuditPersistence.shared.saveSession(category)
            AuditPersistence.shared.saveSession(weekly)
            
            sessions = [monthly, category, weekly]
        }
        
        self.scheduledCounts = sessions.filter { !$0.isSubmitted }.map { session in
            RSMSCycleCount(
                id: session.id,
                title: session.title,
                date: session.date,
                scope: session.scope,
                status: session.status,
                badgeStatus: session.badgeStatus
            )
        }
        
        self.recentAudits = sessions.filter { $0.isSubmitted }.map { session in
            RSMSCycleCount(
                id: session.id,
                title: session.title,
                date: session.date,
                scope: session.scope,
                status: session.status,
                badgeStatus: session.badgeStatus
            )
        }
    }
}
