//
//  POSViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

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
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = CurrencyManager.shared.symbol
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(CurrencyManager.shared.symbol)\(amount)"
    }
}
