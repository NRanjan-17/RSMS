//
//  POSViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import UIKit

@Observable
final class POSViewModel {
    var cartItems: [CartItemModel] = [
        CartItemModel(brand: "Rolex", name: "Submariner Date 126610LN", price: 1450000, qty: 1),
        CartItemModel(brand: "Bottega", name: "The Jodie Hobo Intrecciato", price: 245000, qty: 1)
    ]
    
    var subtotal: Int = 1695000
    var discountRate: Double = 0.08
    var taxFree: Bool = false
    var approvalState: MockApprovalState = .waiting
    var offlineCartQueued: Bool = true
    
    var isProcessingPayment: Bool = false
    var paymentError: String? = nil
    var lastTransactionId: String? = nil
    
    var discount: Int {
        Int(Double(subtotal) * discountRate)
    }
    
    var tax: Int {
        taxFree ? 0 : Int(Double(subtotal - discount) * 0.03)
    }
    
    var total: Int {
        subtotal - discount + tax
    }
    
    var requiresApproval: Bool {
        discountRate > 0.10
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
    
    func completeMockPayment() {
        offlineCartQueued = false
    }
    
    @MainActor
    func processPayment(presentingViewController: UIViewController) async -> Bool {
        isProcessingPayment = true
        paymentError = nil
        
        do {
            let transactionId = try await PaymentService.shared.processPayment(
                amount: Double(total),
                presentingViewController: presentingViewController
            )
            
            self.lastTransactionId = transactionId
            self.offlineCartQueued = false
            self.isProcessingPayment = false
            return true
        } catch {
            self.paymentError = error.localizedDescription
            self.isProcessingPayment = false
            return false
        }
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = CurrencyManager.shared.symbol
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(CurrencyManager.shared.symbol)\(amount)"
    }
}
