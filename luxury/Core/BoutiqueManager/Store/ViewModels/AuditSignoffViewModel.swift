//
//  AuditSignoffViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class AuditSignoffViewModel {
    var variances: [RSMSVarianceItem] = []
    var netVariance: String = "0"
    var accuracy: String = "100%"
    var pendingSession: AuditSession? = nil
    
    init() {
        loadPendingSession()
    }
    
    func loadPendingSession() {
        let sessions = AuditPersistence.shared.loadAllSessions()
        if let submittedSession = sessions.first(where: { $0.status == "Submitted" }) {
            self.pendingSession = submittedSession
            
            if let report = submittedSession.varianceReport {
                self.variances = report.items.map { item in
                    let diff = item.variance
                    let reason: String
                    if diff < 0 {
                        reason = "Missing / Under Investigation"
                    } else if diff > 0 {
                        reason = "Surplus / Unexpected SKU"
                    } else {
                        reason = "Matched"
                    }
                    return RSMSVarianceItem(
                        id: item.id,
                        name: item.productName,
                        expected: item.expectedQty,
                        actual: item.countedQty,
                        reason: reason
                    )
                }
                
                let totalExpected = report.items.reduce(0) { $0 + $1.expectedQty }
                let totalCounted = report.items.reduce(0) { $0 + $1.countedQty }
                let netDiff = totalCounted - totalExpected
                self.netVariance = "\(netDiff > 0 ? "+" : "")\(netDiff)"
                
                let totalAbsoluteVariance = report.items.reduce(0) { $0 + abs($1.variance) }
                if totalExpected > 0 {
                    let accuracyDouble = max(0.0, 1.0 - (Double(totalAbsoluteVariance) / Double(totalExpected)))
                    self.accuracy = String(format: "%.1f%%", accuracyDouble * 100.0)
                } else {
                    self.accuracy = "100%"
                }
            }
        } else {
            // Fallback to default mock data if no submitted session exists
            self.variances = [
                RSMSVarianceItem(name: "Diamond Ring 18K Gold", expected: 5, actual: 4, reason: "Missing / Under Investigation"),
                RSMSVarianceItem(name: "Silk Scarf (Print A)", expected: 10, actual: 12, reason: "Found Elsewhere (Zone B)"),
                RSMSVarianceItem(name: "Men's Wallet Brown", expected: 8, actual: 7, reason: "Damaged / Scrapped")
            ]
            self.netVariance = "-1"
            self.accuracy = "98.2%"
        }
    }
    
    func signoffAudit() {
        guard var session = pendingSession else { return }
        session.status = "Signed Off"
        session.badgeStatus = .success
        AuditPersistence.shared.saveSession(session)
    }
}
