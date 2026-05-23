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
    let scannerService: ScannerService
    
    var scannedItems: [InventoryScanItem] = []
    var totalScanned: Int = 0
    var isPaused: Bool = false
    var errorMessage: String?
    var isProcessing: Bool = false
    var isShowingManualEntry: Bool = false
    var manualEntryText: String = ""
    
    private let barcodeScanService: BarcodeScanService
    private var scannedQuantities: [UUID: Int] = [:]
    private var shouldResumeAfterManualEntry = false
    
    init(
        scannerService: ScannerService = ScannerService(),
        barcodeScanService: BarcodeScanService = BarcodeScanService()
    ) {
        self.scannerService = scannerService
        self.barcodeScanService = barcodeScanService
        self.scannerService.continuousMode = true
        self.scannerService.debounceSeconds = 0.75
        self.scannerService.onScannedCode = { [weak self] code in
            self?.handleScannedCode(code)
        }
    }
    
    func startScan() {
        isPaused = false
        scannerService.resetDebounce()
        scannerService.start()
    }
    
    func pauseSession() {
        isPaused = true
        scannerService.stop()
    }
    
    func completeSession() {
        pauseSession()
    }
    
    func openManualEntry() {
        shouldResumeAfterManualEntry = !isPaused
        pauseSession()
        manualEntryText = ""
        errorMessage = nil
        isShowingManualEntry = true
    }
    
    func closeManualEntry() {
        isShowingManualEntry = false
        manualEntryText = ""
        
        if shouldResumeAfterManualEntry {
            startScan()
        }
        
        shouldResumeAfterManualEntry = false
    }
    
    func submitManualEntry() {
        let trimmedEntry = manualEntryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEntry.isEmpty, !isProcessing else { return }
        
        isProcessing = true
        
        Task {
            do {
                let payload = try await barcodeScanService.findByManualEntry(trimmedEntry)
                await MainActor.run {
                    self.applySuccessfulScan(payload)
                    self.closeManualEntry()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                    self.scannerService.playErrorFeedback()
                }
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !isPaused, !trimmedCode.isEmpty, !isProcessing else { return }
        
        isProcessing = true
        
        Task {
            do {
                let payload = try await barcodeScanService.scan(barcode: trimmedCode)
                await MainActor.run {
                    self.applySuccessfulScan(payload)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                    self.scannerService.playErrorFeedback()
                }
            }
        }
    }
    
    private func applySuccessfulScan(_ payload: BarcodeScanPayload) {
        let updatedQuantity = (scannedQuantities[payload.product.id] ?? 0) + 1
        scannedQuantities[payload.product.id] = updatedQuantity
        totalScanned += 1
        errorMessage = nil
        isProcessing = false
        scannerService.playSuccessFeedback()
        
        let updatedItem = InventoryScanItem(
            id: payload.product.id,
            barcode: payload.barcode,
            productName: payload.product.name,
            sku: payload.product.catalogId,
            quantity: updatedQuantity
        )
        
        if let existingIndex = scannedItems.firstIndex(where: { $0.id == payload.product.id }) {
            scannedItems.remove(at: existingIndex)
        }
        
        scannedItems.insert(updatedItem, at: 0)
    }
}

struct InventoryScanItem: Identifiable, Hashable {
    let id: UUID
    let barcode: String
    let productName: String
    let sku: String
    let quantity: Int
}
