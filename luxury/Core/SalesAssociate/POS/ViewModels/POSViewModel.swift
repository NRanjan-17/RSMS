//
//  POSViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import UIKit

struct POSCartRow: Identifiable {
    let id = UUID()
    let product: CatalogItem
    var qty: Int
}

@Observable
final class POSViewModel {
    static let shared = POSViewModel()
    
    var availableProducts: [CatalogItem] = []
    var cartItems: [POSCartRow] = []
    var selectedClient: StoreClient? = nil
    
    private init() {}
    
    var discountRate: Double = 0.08
    var taxFree: Bool = false
    var approvalState: ApprovalState = .waiting
    var offlineCartQueued: Bool = true
    
    var isProcessingPayment: Bool = false
    var paymentError: String? = nil
    var lastTransactionId: String? = nil
    
    var isLoadingProducts = false
    var errorMessage: String? = nil
    
    var subtotal: Double {
        cartItems.reduce(0.0) { $0 + ($1.product.amount * Double($1.qty)) }
    }
    
    var discount: Double {
        subtotal * discountRate
    }
    
    var tax: Double {
        taxFree ? 0.0 : (subtotal - discount) * 0.03
    }
    
    var total: Double {
        subtotal - discount + tax
    }
    
    var requiresApproval: Bool {
        discountRate > 0.10
    }
    
    func fetchProducts() {
        isLoadingProducts = true
        Task {
            do {
                let products = try await POSDataService.shared.fetchCatalogs()
                await MainActor.run {
                    self.availableProducts = products
                    self.isLoadingProducts = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoadingProducts = false
                }
            }
        }
    }
    
    func addToCart(_ item: CatalogItem) {
        if let index = cartItems.firstIndex(where: { $0.product.id == item.id }) {
            cartItems[index].qty += 1
        } else {
            cartItems.append(POSCartRow(product: item, qty: 1))
        }
    }
    
    func increaseQty(of id: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == id }) {
            cartItems[index].qty += 1
        }
    }
    
    func decreaseQty(of id: UUID) {
        if let index = cartItems.firstIndex(where: { $0.id == id }) {
            if cartItems[index].qty > 1 {
                cartItems[index].qty -= 1
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    func attachClient(_ client: StoreClient) {
        self.selectedClient = client
    }
    
    func applyDiscount(_ rate: Double) {
        discountRate = rate
        approvalState = rate > 0.10 ? .waiting : .approved
    }
    
    func requestApproval() {
        approvalState = .waiting
    }
    
    func approve() {
        approvalState = .approved
    }
    
    func reject() {
        approvalState = .rejected
    }
    
    @MainActor
    func processPayment(presentingViewController: UIViewController, staffId: UUID, boutiqueId: UUID) async -> Bool {
        isProcessingPayment = true
        paymentError = nil
        
        do {
            // 1. Process payment gateway
            let transactionIdStr = try await PaymentService.shared.processPayment(
                amount: Double(total),
                description: "POS Checkout",
                presentingViewController: presentingViewController
            )
            
            // Generate mock transaction UUID since Razorpay returns a string ID like "pay_..."
            let transactionId = UUID() 
            
            // Extract product IDs multiplied by qty
            var productIds: [UUID] = []
            for item in cartItems {
                for _ in 0..<item.qty {
                    productIds.append(item.product.id)
                }
            }
            
            // 2. Create Cart in DB
            let cart = try await POSDataService.shared.createCart(
                clientId: selectedClient?.id,
                boutiqueId: boutiqueId,
                total: Double(total),
                productIds: productIds
            )
            
            // 3. Complete Checkout in DB
            try await POSDataService.shared.checkout(
                cartId: cart.id,
                transactionId: transactionId,
                staffId: staffId,
                total: Double(total),
                productIds: productIds,
                clientId: selectedClient?.id
            )
            
            self.lastTransactionId = transactionIdStr
            self.offlineCartQueued = false
            self.isProcessingPayment = false
            self.cartItems.removeAll()
            return true
        } catch {
            self.paymentError = error.localizedDescription
            self.isProcessingPayment = false
            return false
        }
    }
    
    func formatCurrency(_ amount: Double) -> String {
        return CurrencyManager.shared.format(amount: amount)
    }
}
