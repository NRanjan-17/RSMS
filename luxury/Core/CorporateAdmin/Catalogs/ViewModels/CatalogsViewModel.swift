//
//  CatalogsViewModel.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import Foundation
import Observation

@Observable
final class CatalogsViewModel {
    var searchText: String = ""
    var products: [ProductEntity] = []
    
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    
    // Form fields
    var newName: String = ""
    var newDescription: String = ""
    var newBrand: String = ""
    var newCategory: ProductCategory = .watches
    var newAvailableStock: String = ""
    var newAmount: String = ""
    var newBarCode: String = ""
    var newStatus: ProductStatus = .active
    
    var showScanner = false
    
    private let catalogService = CatalogService()
    
    var filteredProducts: [ProductEntity] {
        if searchText.isEmpty {
            return products
        }
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(searchText) ||
            product.brand.localizedCaseInsensitiveContains(searchText) ||
            product.productId.localizedCaseInsensitiveContains(searchText) ||
            product.barCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched = try await catalogService.fetchProducts()
                await MainActor.run {
                    self.products = fetched
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
        guard let stock = Int(newAvailableStock), let amount = Double(newAmount) else {
            self.errorMessage = "Invalid stock or amount."
            return
        }
        
        guard !newBarCode.isEmpty else {
            self.errorMessage = "Barcode is required. Please scan a QR code or Barcode."
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
            category: newCategory,
            availableStock: stock,
            amount: amount,
            barCode: newBarCode,
            status: newStatus,
            reserved: []
        )
        
        Task {
            do {
                try await catalogService.addProduct(newProduct)
                await MainActor.run {
                    self.products.append(newProduct)
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
        newCategory = product.category
        newAvailableStock = "\(product.availableStock)"
        newAmount = "\(product.amount)"
        newBarCode = product.barCode
        newStatus = product.status
    }
    
    func updateProduct(_ existingProduct: ProductEntity, completion: @escaping () -> Void) {
        guard let stock = Int(newAvailableStock), let amount = Double(newAmount) else {
            self.errorMessage = "Invalid stock or amount."
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
            category: newCategory,
            availableStock: stock,
            amount: amount,
            barCode: newBarCode,
            status: newStatus,
            reserved: existingProduct.reserved
        )
        
        Task {
            do {
                try await catalogService.updateProduct(updatedProduct)
                await MainActor.run {
                    if let index = self.products.firstIndex(where: { $0.id == updatedProduct.id }) {
                        self.products[index] = updatedProduct
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
                    self.products.removeAll { $0.id == product.id }
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
        newAvailableStock = ""
        newAmount = ""
        newBarCode = ""
        newStatus = .active
    }
}
