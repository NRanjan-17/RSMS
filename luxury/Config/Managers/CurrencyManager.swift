//
//  CurrencyManager.swift
//  luxury
//
//  Created by Aditya Chauhan on 25/05/26.
//

import SwiftUI
import Observation

enum AppCurrency: String, CaseIterable, Identifiable {
    case inr = "INR (₹)"
    case usd = "USD ($)"
    case eur = "EUR (€)"
    case gbp = "GBP (£)"
    case jpy = "JPY (¥)"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .inr: return "₹"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .jpy: return "¥"
        }
    }
}

@Observable
final class CurrencyManager {
    static let shared = CurrencyManager()
    
    private let defaults = UserDefaults.standard
    private let currencyKey = "AppGlobalCurrency"
    
    var currentCurrency: AppCurrency {
        didSet {
            defaults.set(currentCurrency.rawValue, forKey: currencyKey)
        }
    }
    
    var symbol: String {
        currentCurrency.symbol
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "AppGlobalCurrency"), let currency = AppCurrency(rawValue: saved) {
            self.currentCurrency = currency
        } else {
            self.currentCurrency = .inr
        }
    }
    
    func format(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(currentCurrency.symbol)\(formattedNumber)"
    }
}
