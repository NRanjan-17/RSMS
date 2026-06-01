//
//  EndlessAisleViewModel.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import Foundation
import Observation

@Observable
@MainActor
public final class EndlessAisleViewModel {
    public static let shared = EndlessAisleViewModel()
    
    public var mockItems: [EndlessAisle.Item] = []
    public var selectedItem: EndlessAisle.Item?
    public var currentCheckResult: StockResult?
    public var isCheckingStock = false
    
    public var activeRequests: [EndlessAisle.SourcingRequest] = []
    
    private let inventoryService: InventoryService
    
    public init() {
        let item1 = EndlessAisle.Item(
            id: UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!,
            name: "Rolex GMT-Master II",
            sku: "SKU-001",
            price: 14500.00,
            stockDelhi: 0,
            stockParis: 5
        )
        
        let item2 = EndlessAisle.Item(
            id: UUID(uuidString: "bbbbbbbb-cccc-dddd-eeee-ffffffffffff")!,
            name: "Rolex Daytona \"Paul Newman\"",
            sku: "SKU-002",
            price: 32000.00,
            stockDelhi: 0,
            stockParis: 0
        )
        
        let item3 = EndlessAisle.Item(
            id: UUID(uuidString: "cccccccc-dddd-eeee-ffff-000000000000")!,
            name: "Rolex Datejust 41",
            sku: "SKU-003",
            price: 9800.00,
            stockDelhi: 8,
            stockParis: 12
        )
        
        let items = [item1, item2, item3]
        
        var mockDict: [UUID: EndlessAisle.Item] = [:]
        for item in items {
            mockDict[item.id] = item
        }
        
        self.inventoryService = MockInventoryService(mockItems: mockDict)
        self.mockItems = items
    }
    
    public func checkStock(item: EndlessAisle.Item) {
        selectedItem = item
        isCheckingStock = true
        currentCheckResult = nil
        
        Task {
            do {
                let result = try await inventoryService.checkStock(itemId: item.id)
                self.currentCheckResult = result
                self.isCheckingStock = false
            } catch {
                self.isCheckingStock = false
            }
        }
    }
    
    public func createRequest(item: EndlessAisle.Item) {
        let newRequest = EndlessAisle.SourcingRequest(
            id: UUID(),
            item: item,
            sourceStore: "Paris Boutique",
            destinationStore: "DLF Emporio, Delhi",
            status: .pendingBMAproval,
            history: ["Transfer request created by Inventory Controller (Delhi)."],
            lastUpdated: Date()
        )
        activeRequests.append(newRequest)
    }
    
    public func approveBMA(requestId: UUID) {
        guard let idx = activeRequests.firstIndex(where: { $0.id == requestId }) else { return }
        var request = activeRequests[idx]
        request.status = .pendingBMBApproval
        request.history.append("Request approved by Delhi Store Manager. Request sent to Paris Store Manager.")
        request.lastUpdated = Date()
        activeRequests[idx] = request
    }
    
    public func approveBMB(requestId: UUID) {
        guard let idx = activeRequests.firstIndex(where: { $0.id == requestId }) else { return }
        var request = activeRequests[idx]
        request.status = .pendingICBDispatch
        request.history.append("Outgoing transfer authorized by Paris Store Manager. Sent to Paris stockroom for dispatch.")
        request.lastUpdated = Date()
        activeRequests[idx] = request
    }
    
    public func dispatchICB(requestId: UUID) {
        guard let idx = activeRequests.firstIndex(where: { $0.id == requestId }) else { return }
        var request = activeRequests[idx]
        request.status = .dispatched
        request.history.append("Item picked, packed, and handed over to DHL courier by Paris stockroom.")
        request.lastUpdated = Date()
        activeRequests[idx] = request
        
        Task {
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                if let currentIdx = self.activeRequests.firstIndex(where: { $0.id == requestId }) {
                    var currentReq = self.activeRequests[currentIdx]
                    currentReq.history.append("Package departed Paris Hub.")
                    currentReq.lastUpdated = Date()
                    self.activeRequests[currentIdx] = currentReq
                }
            }
            
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                if let currentIdx = self.activeRequests.firstIndex(where: { $0.id == requestId }) {
                    var currentReq = self.activeRequests[currentIdx]
                    currentReq.history.append("Arrived at Delhi Customs. Package cleared.")
                    currentReq.lastUpdated = Date()
                    self.activeRequests[currentIdx] = currentReq
                }
            }
            
            try? await Task.sleep(for: .seconds(3))
            await MainActor.run {
                if let currentIdx = self.activeRequests.firstIndex(where: { $0.id == requestId }) {
                    var currentReq = self.activeRequests[currentIdx]
                    currentReq.history.append("Delivered to DLF Emporio, Delhi. Stock allocated to order.")
                    currentReq.lastUpdated = Date()
                    self.activeRequests[currentIdx] = currentReq
                }
            }
        }
    }
}
