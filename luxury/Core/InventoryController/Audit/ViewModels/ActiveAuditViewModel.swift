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
    var expectedItems: [String] = [
        "Rolex Submariner Date 126610LN",
        "Omega Seamaster 210.30.42",
        "Patek Philippe Nautilus 5711/1A",
        "Cartier Santos de Cartier",
        "Tudor Black Bay Fifty-Eight",
        "Rolex Datejust 41"
    ]

    var scannedItems: [ScannedAuditItem] = [
        ScannedAuditItem(name: "Rolex Submariner Date 126610LN", ok: true),
        ScannedAuditItem(name: "Omega Seamaster 210.30.42", ok: true),
        ScannedAuditItem(name: "Patek Philippe Nautilus 5711/1A", ok: true),
        ScannedAuditItem(name: "Audemars Piguet Royal Oak 15500", ok: false)
    ]

    var signoffState: MockApprovalState = .waiting
    var varianceReason: String = "Unexpected SKU"

    var totalExpected: Int {
        expectedItems.count
    }

    var totalScanned: Int {
        scannedItems.filter { $0.ok }.count
    }

    var progress: Double {
        guard !expectedItems.isEmpty else { return 0 }
        let scannedOkCount = scannedItems.filter { $0.ok }.count
        return min(1.0, Double(scannedOkCount) / Double(expectedItems.count))
    }

    var missingItems: [String] {
        let scannedNames = Set(scannedItems.map { $0.name })
        return expectedItems.filter { !scannedNames.contains($0) }
    }

    func recordScan(name: String, ok: Bool) {
        if !scannedItems.contains(where: { $0.name == name }) {
            scannedItems.insert(ScannedAuditItem(name: name, ok: ok), at: 0)
        }
    }

    func addScannedItems(names: [String]) {
        for name in names {
            if !scannedItems.contains(where: { $0.name == name }) {
                let isOk = expectedItems.contains(name)
                scannedItems.insert(ScannedAuditItem(name: name, ok: isOk), at: 0)
            }
        }
    }

    func submitForSignoff() {
        signoffState = .waiting
    }

    func completeSession() {
        signoffState = .approved
    }
}
