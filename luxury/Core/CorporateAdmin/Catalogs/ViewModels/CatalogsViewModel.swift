//
//  CatalogsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 21/05/26.
//

import Foundation
import Observation

@Observable
final class CatalogsViewModel {
    var searchText: String = ""
    var products: [ProductInventorySummary] = []
    
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    
    // Form fields
    var newName: String = ""
    var newDescription: String = ""
    var newBrand: String = ""
    var newCategory: ProductCategory = .watches
    var newCollection: String = ""
    var newAmount: String = ""
    var newBarCode: String = ""
    var newStatus: ProductStatus = .active
    
    var showScanner = false
    
    private let catalogService = CatalogService()
    
    var filteredProducts: [ProductInventorySummary] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { summary in
            summary.product.name.localizedCaseInsensitiveContains(searchText) ||
            summary.product.brand.localizedCaseInsensitiveContains(searchText) ||
            summary.product.productId.localizedCaseInsensitiveContains(searchText) ||
            summary.product.barCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let productsResponse = try await catalogService.fetchProducts()
                let inventoryResponse = try await catalogService.fetchInventory()
                let boutiquesResponse = try await catalogService.fetchBoutiques()
                
                var newSummaries: [ProductInventorySummary] = []
                
                for product in productsResponse {
                    let productInventory = inventoryResponse.filter { $0.skuId == product.id }
                    var locations: [LocationInventoryDetail] = []
                    var totalQty = 0
                    
                    for item in productInventory {
                        totalQty += item.quantity
                        let storeName = boutiquesResponse.first(where: { $0.id == item.storeId })?.name ?? "Unknown Location"
                        locations.append(LocationInventoryDetail(
                            storeId: item.storeId,
                            storeName: storeName,
                            quantity: item.quantity,
                            isAvailable: item.productAvailable
                        ))
                    }
                    
                    newSummaries.append(ProductInventorySummary(
                        product: product,
                        totalQuantity: totalQty,
                        locations: locations.sorted(by: { $0.storeName < $1.storeName })
                    ))
                }
                
                await MainActor.run {
                    self.products = newSummaries.sorted(by: { $0.product.name < $1.product.name })
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func addProduct(completion: @escaping () -> Void) {
        guard let amount = Double(newAmount) else {
            self.errorMessage = "Invalid amount."
            return
        }
        
        guard !newBrand.isEmpty else {
            self.errorMessage = "Brand is required."
            return
        }
        
        guard !newBarCode.isEmpty else {
            self.errorMessage = "Barcode is required."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let newProduct = ProductEntity(
            id: UUID(),
            productId: UUID().uuidString.prefix(8).uppercased(),
            name: newName,
            description: newDescription,
            brand: newBrand,
            category: newCategory.rawValue,
            availableStock: 0,
            amount: amount,
            barCode: newBarCode,
            reserved: [],
            status: newStatus.rawValue,
            collection: newCollection.isEmpty ? nil : newCollection
        )
        
        Task {
            do {
                try await catalogService.addProduct(newProduct)
                await MainActor.run {
                    // Create an empty summary for the new product
                    let newSummary = ProductInventorySummary(product: newProduct, totalQuantity: 0, locations: [])
                    self.products.append(newSummary)
                    self.products.sort(by: { $0.product.name < $1.product.name })
                    self.isSaving = false
                    self.resetForm()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add product: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func populateForm(with product: ProductEntity) {
        newName = product.name
        newDescription = product.description
        newBrand = product.brand
        if let cat = ProductCategory(rawValue: product.category) {
            newCategory = cat
        } else {
            newCategory = .other
        }
        newCollection = product.collection ?? ""
        newAmount = "\(product.amount)"
        newBarCode = product.barCode
        if let stat = ProductStatus(rawValue: product.status) {
            newStatus = stat
        } else {
            newStatus = .active
        }
    }
    
    func updateProduct(_ existingProduct: ProductEntity, completion: @escaping () -> Void) {
        guard let amount = Double(newAmount) else {
            self.errorMessage = "Invalid amount."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let updatedProduct = ProductEntity(
            id: existingProduct.id,
            productId: existingProduct.productId,
            name: newName,
            description: newDescription,
            brand: newBrand,
            category: newCategory.rawValue,
            availableStock: existingProduct.availableStock,
            amount: amount,
            barCode: newBarCode,
            reserved: existingProduct.reserved,
            status: newStatus.rawValue,
            collection: newCollection.isEmpty ? nil : newCollection
        )
        
        Task {
            do {
                try await catalogService.updateProduct(updatedProduct)
                await MainActor.run {
                    if let index = self.products.firstIndex(where: { $0.product.id == updatedProduct.id }) {
                        let oldSummary = self.products[index]
                        self.products[index] = ProductInventorySummary(product: updatedProduct, totalQuantity: oldSummary.totalQuantity, locations: oldSummary.locations)
                    }
                    self.isSaving = false
                    self.resetForm()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update product: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func deleteProduct(_ product: ProductEntity, completion: @escaping () -> Void) {
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                try await catalogService.deleteProduct(id: product.id)
                await MainActor.run {
                    self.products.removeAll { $0.product.id == product.id }
                    self.isSaving = false
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete product: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func resetForm() {
        newName = ""
        newDescription = ""
        newBrand = ""
        newCategory = .watches
        newCollection = ""
        newAmount = ""
        newBarCode = ""
        newStatus = .active
    }
}
