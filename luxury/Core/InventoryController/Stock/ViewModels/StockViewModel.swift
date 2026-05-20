//
//  StockViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class StockViewModel {
    var totalItems: String = "1,284"
    var lowStockCount: String = "12"
    var outOfStockCount: String = "5"
    
    var alerts: [InventoryAlert] = [
        InventoryAlert(itemName: "Royal Oak Selfwinding", sku: "AP-15500ST", currentQty: 0, status: .error),
        InventoryAlert(itemName: "Serpenti Seduttori", sku: "BV-103145", currentQty: 1, status: .warning),
        InventoryAlert(itemName: "Oyster Perpetual 41", sku: "RX-124300", currentQty: 0, status: .error),
        InventoryAlert(itemName: "Tank Louis Cartier", sku: "CR-WGTA0011", currentQty: 2, status: .warning)
    ]
}
