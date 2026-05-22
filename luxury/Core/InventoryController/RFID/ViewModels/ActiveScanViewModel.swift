//
//  ActiveScanViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

struct SavedScanSession: Codable {
    let sessionId: UUID
    let scannedTags: [RFIDTag]
    let progress: Double
    let totalExpected: Int
    let isPaused: Bool
    let lastSavedTimestamp: Date
}

@Observable
@MainActor
final class ActiveScanViewModel {
    var sessionId = UUID()
    var scannedTags: [RFIDTag] = []
    var progress: Double = 0.0
    var totalExpected: Int = 120
    var isPaused: Bool = false
    var duplicateDetected: Bool = false
    var unknownItemDetected: Bool = false
    var show24hWarning: Bool = false
    var offlineQueue: [RFIDTag] = []
    var lastSavedTimestamp: Date?
    var isSyncing: Bool = false
    
    var totalScanned: Int { scannedTags.filter { $0.ok }.count }
    
    private var networkObservationTask: Task<Void, Never>?
    
    init() {
        startNetworkMonitoring()
    }
    
    deinit {
        networkObservationTask?.cancel()
    }
    
    func startNetworkMonitoring() {
        networkObservationTask = Task { [weak self] in
            while !Task.isCancelled {
                if NetworkMonitor.shared.isConnected {
                    await self?.syncOfflineScans()
                }
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                } catch {
                    break
                }
            }
        }
    }
    
    func startScan() {
        isPaused = false
    }
    
    func pauseSession() {
        isPaused = true
        pauseAndSaveSession()
    }
    
    func recordScan(epc: String, name: String, ok: Bool) {
        duplicateDetected = scannedTags.contains { $0.epc == epc }
        unknownItemDetected = !ok
        
        let tag = RFIDTag(epc: epc, name: name, ok: ok)
        scannedTags.insert(tag, at: 0)
        progress = min(1, Double(totalScanned) / Double(totalExpected))
        
        if NetworkMonitor.shared.isConnected {
            Task {
                await uploadScan(tag)
            }
        } else {
            offlineQueue.append(tag)
            saveOfflineQueue()
        }
        
        pauseAndSaveSession()
    }
    
    func completeSession() {
        progress = min(1, Double(totalScanned) / Double(totalExpected))
        clearSavedSession()
    }
    
    func pauseAndSaveSession() {
        let now = Date()
        lastSavedTimestamp = now
        
        let sessionToSave = SavedScanSession(
            sessionId: sessionId,
            scannedTags: scannedTags,
            progress: progress,
            totalExpected: totalExpected,
            isPaused: true,
            lastSavedTimestamp: now
        )
        
        if let encoded = try? JSONEncoder().encode(sessionToSave) {
            UserDefaults.standard.set(encoded, forKey: "luxury.active_scan_session")
        }
        saveOfflineQueue()
    }
    
    func checkAndRestoreSession() {
        if let data = UserDefaults.standard.data(forKey: "luxury.active_scan_session"),
           let restored = try? JSONDecoder().decode(SavedScanSession.self, from: data) {
            let timePassed = Date().timeIntervalSince(restored.lastSavedTimestamp)
            if timePassed >= 24 * 60 * 60 {
                show24hWarning = true
            }
            
            self.sessionId = restored.sessionId
            self.scannedTags = restored.scannedTags
            self.progress = restored.progress
            self.totalExpected = restored.totalExpected
            self.isPaused = true
            self.lastSavedTimestamp = restored.lastSavedTimestamp
        }
        
        if let data = UserDefaults.standard.data(forKey: "luxury.offline_scan_queue"),
           let restoredQueue = try? JSONDecoder().decode([RFIDTag].self, from: data) {
            self.offlineQueue = restoredQueue
        }
    }
    
    func clearSavedSession() {
        UserDefaults.standard.removeObject(forKey: "luxury.active_scan_session")
        UserDefaults.standard.removeObject(forKey: "luxury.offline_scan_queue")
        sessionId = UUID()
        scannedTags = []
        progress = 0.0
        isPaused = false
        duplicateDetected = false
        unknownItemDetected = false
        show24hWarning = false
        offlineQueue = []
        lastSavedTimestamp = nil
    }
    
    private func saveOfflineQueue() {
        if let encoded = try? JSONEncoder().encode(offlineQueue) {
            UserDefaults.standard.set(encoded, forKey: "luxury.offline_scan_queue")
        }
    }
    
    func syncOfflineScans() async {
        guard !isSyncing, !offlineQueue.isEmpty else { return }
        isSyncing = true
        
        var remainingQueue = offlineQueue
        while !remainingQueue.isEmpty {
            let nextTag = remainingQueue[0]
            do {
                try await performUpload(nextTag)
                remainingQueue.removeFirst()
                self.offlineQueue = remainingQueue
                saveOfflineQueue()
            } catch {
                break
            }
        }
        isSyncing = false
    }
    
    private func uploadScan(_ tag: RFIDTag) async {
        do {
            try await performUpload(tag)
        } catch {
            offlineQueue.append(tag)
            saveOfflineQueue()
        }
    }
    
    private func performUpload(_ tag: RFIDTag) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
    }
}
