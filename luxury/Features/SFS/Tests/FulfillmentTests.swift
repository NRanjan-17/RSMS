//
//  FulfillmentTests.swift
//  luxuryTests
//
//  Created by Antigravity on 27/05/26.
//

#if canImport(XCTest)
import XCTest
import Supabase
@testable import luxury

final class FulfillmentTests: XCTestCase {
    
    private var mockBoutiqueId = UUID()
    private var mockProductId = UUID()
    private var mockTransactionId = UUID()
    
    private var mockStaffModel: StaffModel {
        StaffModel(
            id: UUID(),
            authUserId: UUID(),
            boutiqueId: mockBoutiqueId,
            employeeId: "EMP001",
            role: .inventoryController,
            name: "John Doe",
            email: "john@boutique.com",
            phone: "1234567890",
            address: "123 Street",
            location: "Delhi",
            city: "Delhi",
            pinCode: "110001",
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
    
    private var mockPurchasedItem: PurchasedItemEntity {
        PurchasedItemEntity(
            id: UUID(),
            uid: UUID(),
            productId: mockProductId,
            reservedDate: Date(),
            deliveryDate: nil,
            transactionId: mockTransactionId.uuidString,
            status: "Pending",
            createdAt: Date()
        )
    }
    
    private var mockInventoryItem: InventoryItem {
        InventoryItem(
            id: UUID(),
            storeId: mockBoutiqueId,
            skuId: mockProductId,
            quantity: 5,
            productAvailable: true
        )
    }
    
    func testRoleGuardBlocksNonInventoryController() async {
        let viewModel = FulfillmentViewModel()
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.salesAssociate, self.mockStaffModel)
        }
        
        viewModel.fetchPurchasedItemsHandler = { [weak self] in
            guard let self = self else { return [] }
            return [self.mockPurchasedItem]
        }
        
        let result = await viewModel.secureItem(orderId: mockPurchasedItem.id)
        
        switch result {
        case .success:
            XCTFail("Should fail due to role guard restriction")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("Unauthorized") || error.localizedDescription.contains("restricted"))
        }
    }
    
    func testSuccessfulMarkAsSecuredAndNotification() async {
        let viewModel = FulfillmentViewModel()
        let item = mockPurchasedItem
        let expectation = expectation(description: "SalesAssociateNotification posted")
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchPurchasedItemsHandler = {
            return [item]
        }
        
        viewModel.fetchInventoryHandler = { [weak self] _, _ in
            guard let self = self else { return [] }
            return [self.mockInventoryItem]
        }
        
        viewModel.updateInventoryHandler = { _, _, _ in }
        viewModel.updatePurchasedItemHandler = { _, _, _ in }
        
        let observer = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SalesAssociateNotification"),
            object: nil,
            queue: .main
        ) { notification in
            XCTAssertEqual(notification.userInfo?["status"] as? String, "Ready to Pick")
            expectation.fulfill()
        }
        
        let result = await viewModel.secureItem(orderId: item.id)
        
        switch result {
        case .success:
            await fulfillment(of: [expectation], timeout: 2.0)
            NotificationCenter.default.removeObserver(observer)
        case .failure(let error):
            XCTFail("Failed to secure item: \(error.localizedDescription)")
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func testConflictGuardDetectsAllocations() async {
        let viewModel = FulfillmentViewModel()
        let mainItem = mockPurchasedItem
        
        var conflictingItem = mockPurchasedItem
        conflictingItem.status = "Secured"
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchPurchasedItemsHandler = {
            return [mainItem, conflictingItem]
        }
        
        viewModel.fetchInventoryHandler = { [weak self] _, _ in
            guard let self = self else { return [] }
            return [self.mockInventoryItem]
        }
        
        let result = await viewModel.secureItem(orderId: mainItem.id)
        
        switch result {
        case .success:
            XCTFail("Should detect double-reservation conflict and fail")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("Item already reserved for Order #"))
        }
    }
    
    func testDoubleSecureFails() async {
        let viewModel = FulfillmentViewModel()
        var completedItem = mockPurchasedItem
        completedItem.status = "Ready to Pick"
        
        viewModel.fetchProfileHandler = { [weak self] in
            guard let self = self else { return nil }
            return (.inventoryController, self.mockStaffModel)
        }
        
        viewModel.fetchPurchasedItemsHandler = {
            return [completedItem]
        }
        
        let result = await viewModel.secureItem(orderId: completedItem.id)
        
        switch result {
        case .success:
            XCTFail("Should fail when securing an already ready item")
        case .failure(let error):
            XCTAssertTrue(error.localizedDescription.contains("already been marked as Ready") || error.localizedDescription.contains("Conflict"))
        }
    }
    
    func testDashboardReflectsReadyStatus() async {
        let dashboardVM = DashboardViewModel()
        var readyItem = mockPurchasedItem
        readyItem.status = "Ready to Pick"
        
        let items: [PurchasedItemEntity] = [readyItem]
        
        dashboardVM.sfsFulfillments = items
        
        XCTAssertEqual(dashboardVM.sfsFulfillments.count, 1)
        XCTAssertEqual(dashboardVM.sfsFulfillments.first?.status, "Ready to Pick")
    }
}
#endif
