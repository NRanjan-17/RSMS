//
//  SellingViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class SellingViewModel {
    var searchText: String = ""
    var selectedCategory: String = "All"
    let categories: [String] = ["All", "Watches", "Leather", "Footwear", "Jewellery"]
    
    var products: [Product] = [
        Product(brand: "Rolex", name: "Submariner Date", price: "₹14,50,000", inStock: true),
        Product(brand: "Hermès", name: "Birkin 30 Togo", price: "₹15,80,000", inStock: true),
        Product(brand: "Patek Philippe", name: "Nautilus 5711/1A", price: "₹82,00,000", inStock: false),
        Product(brand: "Bottega Veneta", name: "The Jodie", price: "₹2,45,000", inStock: true),
        Product(brand: "Louboutin", name: "So Kate 120mm", price: "₹68,000", inStock: true),
        Product(brand: "Omega", name: "Planet Ocean 42", price: "₹3,60,000", inStock: true)
    ]
    
    var filteredProducts: [Product] {
        var filtered = products
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.brand.localizedCaseInsensitiveContains(selectedCategory) || $0.name.localizedCaseInsensitiveContains(selectedCategory) }
        }
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.brand.localizedCaseInsensitiveContains(searchText) }
        }
        return filtered
    }
}
