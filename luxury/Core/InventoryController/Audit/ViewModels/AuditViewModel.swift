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
    var scheduledCounts: [RSMSCycleCount] = [
        RSMSCycleCount(title: "Monthly Full Audit", date: "31 May 2026", scope: "Full Store", status: "Scheduled", badgeStatus: .neutral),
        RSMSCycleCount(title: "High Value Zone", date: "Today", scope: "Watches", status: "Due", badgeStatus: .warning)
    ]
    
    var recentAudits: [RSMSCycleCount] = [
        RSMSCycleCount(title: "Category Audit", date: "12 May 2026", scope: "Leather Goods", status: "Signed Off", badgeStatus: .success),
        RSMSCycleCount(title: "Weekly Quick Scan", date: "08 May 2026", scope: "Zone B", status: "Signed Off", badgeStatus: .success)
    ]
}
