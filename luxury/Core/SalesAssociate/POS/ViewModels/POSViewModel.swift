//
//  POSViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import UIKit

struct POSCartRow: Identifiable, Codable {
    var id = UUID()
    let product: CatalogItem
    var qty: Int
}

@Observable
final class POSViewModel {
    static let shared = POSViewModel()
    
    var availableProducts: [CatalogItem] = []
    
    var clientCarts: [UUID: [POSCartRow]] = [:] {
        didSet { saveCarts() }
    }
    var guestCart: [POSCartRow] = [] {
        didSet { saveCarts() }
    }
    
    var cartItems: [POSCartRow] {
        get {
            if let client = selectedClient {
                return clientCarts[client.id] ?? []
            } else {
                return guestCart
            }
        }
        set {
            if let client = selectedClient {
                clientCarts[client.id] = newValue
            } else {
                guestCart = newValue
            }
        }
    }
    
    var selectedClient: StoreClient? = nil
    
    private init() {
        loadCarts()
    }
    
    private func saveCarts() {
        if let encoded = try? JSONEncoder().encode(clientCarts) {
            UserDefaults.standard.set(encoded, forKey: "savedClientCarts")
        }
        if let encoded = try? JSONEncoder().encode(guestCart) {
            UserDefaults.standard.set(encoded, forKey: "savedGuestCart")
        }
    }

    private func loadCarts() {
        if let savedClientCartsData = UserDefaults.standard.data(forKey: "savedClientCarts"),
           let decoded = try? JSONDecoder().decode([UUID: [POSCartRow]].self, from: savedClientCartsData) {
            self.clientCarts = decoded
        }
        if let savedGuestCartData = UserDefaults.standard.data(forKey: "savedGuestCart"),
           let decoded = try? JSONDecoder().decode([POSCartRow].self, from: savedGuestCartData) {
            self.guestCart = decoded
        }
    }
    
    var courtesyRate: Double = 0.0
    var taxFree: Bool = false
    var approvalState: ApprovalState = .approved
    var offlineCartQueued: Bool = true
    
    var isProcessingPayment: Bool = false
    var paymentError: String? = nil
    var lastTransactionId: String? = nil
    
    var isLoadingProducts = false
    var errorMessage: String? = nil
    
    var subtotal: Int {
        Int(cartItems.reduce(0) { $0 + ($1.product.amount * Double($1.qty)) })
    }
    
    var courtesyAmount: Int {
        Int(Double(subtotal) * courtesyRate)
    }
    
    var tax: Int {
        taxFree ? 0 : Int(Double(subtotal - courtesyAmount) * 0.03)
    }
    
    var total: Int {
        subtotal - courtesyAmount + tax
    }
    
    var requiresApproval: Bool {
        courtesyRate > 0.05
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
    
    func applyCourtesy(_ rate: Double) {
        courtesyRate = rate
        approvalState = rate > 0.05 ? .waiting : .approved
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
    func processPayment(presentingViewController: UIViewController) async -> Bool {
        guard selectedClient != nil else {
            self.paymentError = "A client must be attached to the cart before processing payment."
            return false
        }
        
        isProcessingPayment = true
        paymentError = nil
        
        do {
            guard let result = try await ProfileService().fetchCurrentProfile() else {
                self.paymentError = "Could not find your user profile in the system."
                self.isProcessingPayment = false
                return false
            }
            
            guard let staff = result.1 as? StaffModel else {
                self.paymentError = "Only Sales Associates can process checkouts."
                self.isProcessingPayment = false
                return false
            }
            
            guard let validBoutiqueId = staff.boutiqueId else {
                self.paymentError = "You are not assigned to a boutique yet."
                self.isProcessingPayment = false
                return false
            }
            
            let staffId = staff.id
            let boutiqueId = validBoutiqueId
            
            // 1. Process payment gateway
            let transactionIdStr = try await PaymentService.shared.processPayment(
                amount: Double(total),
                description: "POS Checkout",
                presentingViewController: presentingViewController
            )
            
            // 2. Create Transaction in DB
            let transaction = try await POSDataService.shared.createTransaction(
                amount: Double(total),
                purpose: TransactionPurpose.purchase.rawValue,
                clientId: selectedClient?.id,
                boutiqueId: boutiqueId,
                staffId: staffId
            )
            
            // Extract product IDs multiplied by qty
            var productIds: [UUID] = []
            for item in cartItems {
                for _ in 0..<item.qty {
                    productIds.append(item.product.id)
                }
            }
            
            // 3. Create Cart in DB
            let cart = try await POSDataService.shared.createCart(
                clientId: selectedClient?.id,
                boutiqueId: boutiqueId,
                total: Double(total),
                productIds: productIds
            )
            
            // 4. Complete Checkout in DB
            try await POSDataService.shared.checkout(
                cartId: cart.id,
                transactionId: transaction.id,
                staffId: staffId,
                boutiqueId: boutiqueId,
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
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = CurrencyManager.shared.symbol
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(CurrencyManager.shared.symbol)\(amount)"
    }
}

