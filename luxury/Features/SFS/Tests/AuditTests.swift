//
//  AuditTests.swift
//  luxuryTests
//
//  Created by Nalinish Ranjan on 27/05/26.
//

#if canImport(XCTest)
import XCTest
import Supabase
@testable import luxury

final class AuditTests: XCTestCase {
    
    private var mockBoutiqueId = UUID()
    
    private var mockStaffModel: StaffModel {
        StaffModel(
            id: UUID(),
            authUserId: UUID(),
            boutiqueId: mockBoutiqueId,
            employeeId: "EMP002",
            role: .inventoryController,
            name: "John Controller",
            email: "john.c@boutique.com",
            phone: "1234567890",
            address: "456 Street",
            location: "Mumbai",
            city: "Mumbai",
            pinCode: "400001",
            resumeUrl: "http://resume",
            provider: "email",
            avatarUrl: "http://avatar",
            certificationUrl: nil,
            status: .approved,
            createdAt: Date(),
            updatedAt: Date(),
            lastLoginAt: nil,
            onBoardingCompleted: true
        )
    }
    
    private var mockCatalogs: [CatalogEntity] {
        [
            CatalogEntity(id: UUID(), catalogId: "RX-1", name: "Rolex Daytona", description: "Oystersteel", brand: "Rolex", category: .watches, amount: 1500000.0, barCode: "BAR-1", status: .active, reserved: nil, productIds: nil, productImages: nil),
            CatalogEntity(id: UUID(), catalogId: "OM-1", name: "Omega Speedmaster", description: "Co-Axial", brand: "Omega", category: .watches, amount: 600000.0, barCode: "BAR-2", status: .active, reserved: nil, productIds: nil, productImages: nil),
            CatalogEntity(id: UUID(), catalogId: "AP-1", name: "AP Royal Oak", description: "Rose Gold", brand: "Audemars Piguet", category: .watches, amount: 3500000.0, barCode: "BAR-3", status: .active, reserved: nil, productIds: nil, productImages: nil)
        ]
    }
    
    private var mockInventory: [InventoryItem] {
        [
            InventoryItem(id: UUID(), storeId: mockBoutiqueId, skuId: mockCatalogs[0].id, quantity: 3, productAvailable: true),
            InventoryItem(id: UUID(), storeId: mockBoutiqueId, skuId: mockCatalogs[1].id, quantity: 2, productAvailable: true),
            InventoryItem(id: UUID(), storeId: mockBoutiqueId, skuId: mockCatalogs[2].id, quantity: 1, productAvailable: true)
        ]
    }
    
    func testVarianceCalculations() async {
        let cycleCount = RSMSCycleCount(title: "Test Audit", date: "Today", scope: "Full Store", status: "Due", badgeStatus: .warning)
        let viewModel = ActiveAuditViewModel(audit: cycleCount)
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchCatalogsHandler = { [weak self] in
            guard let self = self else { return [] }
            return self.mockCatalogs
        }
        
        viewModel.fetchInventoryHandler = { [weak self] _ in
            guard let self = self else { return [] }
            return self.mockInventory
        }
        
        viewModel.fetchBoutiquesHandler = {
            return []
        }
        
        await viewModel.loadExpectedItems()
        
        XCTAssertEqual(viewModel.expectedItems.count, 3)
        
        let _ = viewModel.scanItem(barcode: "BAR-1")
        let _ = viewModel.scanItem(barcode: "BAR-1")
        let _ = viewModel.scanItem(barcode: "BAR-1")
        let _ = viewModel.scanItem(barcode: "BAR-1")
        
        let _ = viewModel.scanItem(barcode: "BAR-2")
        
        let submitResult = await viewModel.submitCount()
        
        switch submitResult {
        case .success(let report):
            XCTAssertEqual(report.items.count, 3)
            
            let overItem = report.items.first { $0.sku == "RX-1" }
            XCTAssertNotNil(overItem)
            XCTAssertEqual(overItem?.variance, 1)
            
            let underItem = report.items.first { $0.sku == "OM-1" }
            XCTAssertNotNil(underItem)
            XCTAssertEqual(underItem?.variance, -1)
            
            let zeroItem = report.items.first { $0.sku == "AP-1" }
            XCTAssertNotNil(zeroItem)
            XCTAssertEqual(zeroItem?.variance, -1)
        case .failure(let error):
            XCTFail("Failed to submit count: \(error.localizedDescription)")
        }
    }
    
    func testArchivedProductHandling() async {
        let cycleCount = RSMSCycleCount(title: "Test Audit", date: "Today", scope: "Full Store", status: "Due", badgeStatus: .warning)
        let viewModel = ActiveAuditViewModel(audit: cycleCount)
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchCatalogsHandler = { [weak self] in
            guard let self = self else { return [] }
            return self.mockCatalogs
        }
        
        viewModel.fetchInventoryHandler = { [weak self] _ in
            guard let self = self else { return [] }
            return self.mockInventory
        }
        
        viewModel.fetchBoutiquesHandler = {
            return []
        }
        
        await viewModel.loadExpectedItems()
        
        viewModel.fetchCatalogsHandler = { [weak self] in
            guard let self = self else { return [] }
            return Array(self.mockCatalogs.dropFirst())
        }
        
        let submitResult = await viewModel.submitCount()
        
        switch submitResult {
        case .success(let report):
            let archivedItem = report.items.first { $0.sku == "RX-1" }
            XCTAssertNotNil(archivedItem)
            XCTAssertTrue(archivedItem?.isArchivedProduct ?? false)
        case .failure(let error):
            XCTFail("Failed to submit count: \(error.localizedDescription)")
        }
    }
    
    func testZeroItemsScanned() async {
        let cycleCount = RSMSCycleCount(title: "Test Audit", date: "Today", scope: "Full Store", status: "Due", badgeStatus: .warning)
        let viewModel = ActiveAuditViewModel(audit: cycleCount)
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchCatalogsHandler = { [weak self] in
            guard let self = self else { return [] }
            return self.mockCatalogs
        }
        
        viewModel.fetchInventoryHandler = { [weak self] _ in
            guard let self = self else { return [] }
            return self.mockInventory
        }
        
        viewModel.fetchBoutiquesHandler = {
            return []
        }
        
        await viewModel.loadExpectedItems()
        
        let submitResult = await viewModel.submitCount()
        
        switch submitResult {
        case .success(let report):
            XCTAssertTrue(report.items.allSatisfy { $0.countedQty == 0 })
            XCTAssertTrue(report.items.allSatisfy { $0.variance < 0 })
        case .failure(let error):
            XCTFail("Failed to submit count: \(error.localizedDescription)")
        }
    }
}
#endif
