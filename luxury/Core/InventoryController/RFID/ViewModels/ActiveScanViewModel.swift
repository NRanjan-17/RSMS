//
//  ActiveScanViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class ActiveScanViewModel {
    var scannedTags: [RFIDTag] = [
        RFIDTag(epc: "E200001896180...1234", name: "Rolex Submariner 126610LN", ok: true),
        RFIDTag(epc: "E200001896180...1235", name: "Omega Seamaster 210.30.42", ok: true),
        RFIDTag(epc: "E200001896180...1236", name: "⚠ Unmatched tag", ok: false),
        RFIDTag(epc: "E200001896180...1237", name: "Patek Philippe Nautilus 5711", ok: true)
    ]
    
    var progress: Double = 0.65
    var totalExpected: Int = 120
    var totalScanned: Int { scannedTags.filter { $0.ok }.count }
    var isPaused: Bool = false
    var duplicateDetected: Bool = false
    var unknownItemDetected: Bool = true
    
    func startScan() {
        isPaused = false
    }
    
    func pauseSession() {
        isPaused = true
    }
    
    func recordScan(epc: String, name: String, ok: Bool) {
        duplicateDetected = scannedTags.contains { $0.epc == epc }
        unknownItemDetected = !ok
        scannedTags.insert(RFIDTag(epc: epc, name: name, ok: ok), at: 0)
        progress = min(1, Double(totalScanned) / Double(totalExpected))
    }
    
    func completeSession() {
        progress = min(1, Double(totalScanned) / Double(totalExpected))
    }
}
