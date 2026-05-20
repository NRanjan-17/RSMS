//
//  RFIDViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class RFIDViewModel {
    var recentSessions: [ScanSession] = [
        ScanSession(date: "Today, 10:30 AM", zone: "Showcase A", scannedCount: 42, expectedCount: 42, variance: 0),
        ScanSession(date: "Yesterday, 04:15 PM", zone: "Vault", scannedCount: 118, expectedCount: 120, variance: -2),
        ScanSession(date: "13 May, 09:00 AM", zone: "Window Display", scannedCount: 15, expectedCount: 15, variance: 0)
    ]
}
