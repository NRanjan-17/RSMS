//
//  ActiveAuditViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ActiveAuditViewModel {
    var scannedItems: [ScannedAuditItem] = [
        ScannedAuditItem(name: "Rolex Submariner Date 126610LN", ok: true),
        ScannedAuditItem(name: "Omega Seamaster 210.30.42", ok: true),
        ScannedAuditItem(name: "Patek Philippe Nautilus 5711/1A", ok: true),
        ScannedAuditItem(name: "Audemars Piguet Royal Oak 15500", ok: false)
    ]
    
    var totalExpected: Int = 85
    var totalScanned: Int = 42
    var signoffState: ApprovalState = .waiting
    var varianceReason: String = "Unexpected SKU"
    var progress: Double { Double(totalScanned) / Double(totalExpected) }
    
    func recordScan(name: String, ok: Bool) {
        scannedItems.insert(ScannedAuditItem(name: name, ok: ok), at: 0)
        totalScanned += 1
    }
    
    func submitForSignoff() {
        signoffState = .waiting
    }
    
    func completeSession() {
        signoffState = .approved
    }
}
