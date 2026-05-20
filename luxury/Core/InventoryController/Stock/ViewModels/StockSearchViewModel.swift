//
//  StockSearchViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class StockSearchViewModel {
    var searchText: String = ""
    var stockItems: [StockItem] = [
        StockItem(brand: "Rolex", name: "Submariner Date 126610LN", qty: 3, rfid: true, alert: false),
        StockItem(brand: "Hermès", name: "Birkin 30 Togo Noir", qty: 1, rfid: true, alert: true),
        StockItem(brand: "Patek Philippe", name: "Nautilus 5711/1A Acier", qty: 0, rfid: true, alert: true),
        StockItem(brand: "Bottega Veneta", name: "The Jodie Hobo Kiwi", qty: 5, rfid: false, alert: false)
    ]
    
    var filteredItems: [StockItem] {
        if searchText.isEmpty {
            return stockItems
        }
        return stockItems.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.brand.localizedCaseInsensitiveContains(searchText) }
    }
}
