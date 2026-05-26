//
//  CatalogsViewModel.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import Foundation
import Observation
import PhotosUI
import SwiftUI

@Observable
final class CatalogsViewModel {
    var searchText: String = ""
    var catalogs: [CatalogEntity] = []
    
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    
    // Form fields
    var newName: String = ""
    var newDescription: String = ""
    var newBrand: String = ""
    var newCategory: CatalogCategory = .watches
    var newAmount: String = ""
    var newBarCode: String = ""
    var newStatus: CatalogStatus = .active
    
    // Image fields
    var selectedPhotoItems: [PhotosPickerItem] = []
    var existingImageURLs: [String] = []
    var selectedImagesData: [Data] = []
    
    var showScanner = false
    
    private let catalogService = CatalogService()
    private let imagePickerService = ImagePickerService()
    private let storageService = StorageService()
    
    var filteredCatalogs: [CatalogEntity] {
        if searchText.isEmpty {
            return catalogs
        }
        return catalogs.filter { catalog in
            catalog.name.localizedCaseInsensitiveContains(searchText) ||
            catalog.brand.localizedCaseInsensitiveContains(searchText) ||
            catalog.catalogId.localizedCaseInsensitiveContains(searchText) ||
            catalog.barCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetched = try await catalogService.fetchCatalogs()
                await MainActor.run {
                    self.catalogs = fetched
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load catalogs: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func addCatalog(completion: @escaping () -> Void) {
        guard let amount = Double(newAmount) else {
            self.errorMessage = "Invalid amount."
            return
        }
        
        guard !newBarCode.isEmpty else {
            self.errorMessage = "QR/Barcode string is required."
            return
        }
        
        if catalogs.contains(where: { $0.catalogId == newBarCode }) {
            self.errorMessage = "Duplicate catalog detected! A catalog with this barcode already exists."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let newCatalog = CatalogEntity(
            id: UUID(),
            catalogId: newBarCode, // Treat fetched string as catalogId
            name: newName,
            description: newDescription,
            brand: newBrand,
            category: newCategory,
            amount: amount,
            barCode: newBarCode,
            status: newStatus,
            reserved: nil,
            productIds: nil,
            productImages: nil
        )
        
        Task {
            do {
                // Upload images first
                var uploadedURLs: [String] = []
                
                for item in selectedPhotoItems {
                    if let asset = try? await imagePickerService.loadImage(from: item) {
                        if let url = try? await storageService.uploadCatalogImage(image: asset) {
                            uploadedURLs.append(url)
                        }
                    }
                }
                
                var catalogToSave = newCatalog
                catalogToSave.productImages = uploadedURLs
                
                try await catalogService.addCatalog(catalogToSave)
                SystemLogService.shared.logAction(category: .inventory, severity: .info, message: "Added new catalog \(catalogToSave.name) (\(catalogToSave.catalogId))")
                await MainActor.run {
                    self.catalogs.append(catalogToSave)
                    self.isSaving = false
                    self.resetForm()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add catalog: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func populateForm(with catalog: CatalogEntity) {
        newName = catalog.name
        newDescription = catalog.description
        newBrand = catalog.brand
        newCategory = catalog.category
        newAmount = "\(catalog.amount)"
        newBarCode = catalog.barCode
        newStatus = catalog.status
        existingImageURLs = catalog.productImages ?? []
        selectedPhotoItems = []
    }
    
    func updateCatalog(_ existingCatalog: CatalogEntity, completion: @escaping () -> Void) {
        guard let amount = Double(newAmount) else {
            self.errorMessage = "Invalid amount."
            return
        }
        
        isSaving = true
        errorMessage = nil
        
        let updatedCatalog = CatalogEntity(
            id: existingCatalog.id,
            catalogId: existingCatalog.catalogId,
            name: newName,
            description: newDescription,
            brand: newBrand,
            category: newCategory,
            amount: amount,
            barCode: newBarCode,
            status: newStatus,
            reserved: existingCatalog.reserved,
            productIds: existingCatalog.productIds,
            productImages: existingCatalog.productImages
        )
        
        Task {
            do {
                // Upload new images
                var uploadedURLs: [String] = existingImageURLs
                
                for item in selectedPhotoItems {
                    if let asset = try? await imagePickerService.loadImage(from: item) {
                        if let url = try? await storageService.uploadCatalogImage(image: asset) {
                            uploadedURLs.append(url)
                        }
                    }
                }
                
                var catalogToUpdate = updatedCatalog
                catalogToUpdate.productImages = uploadedURLs
                
                try await catalogService.updateCatalog(catalogToUpdate)
                SystemLogService.shared.logAction(category: .inventory, severity: .info, message: "Updated catalog \(catalogToUpdate.name) (\(catalogToUpdate.catalogId))")
                await MainActor.run {
                    if let index = self.catalogs.firstIndex(where: { $0.id == updatedCatalog.id }) {
                        self.catalogs[index] = catalogToUpdate
                    }
                    self.isSaving = false
                    self.resetForm()
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update catalog: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func deleteCatalog(_ catalog: CatalogEntity, completion: @escaping () -> Void) {
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                try await catalogService.deleteCatalog(id: catalog.id)
                SystemLogService.shared.logAction(category: .inventory, severity: .warning, message: "Deleted catalog \(catalog.name) (\(catalog.catalogId))")
                await MainActor.run {
                    self.catalogs.removeAll { $0.id == catalog.id }
                    self.isSaving = false
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to delete catalog: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func addSerialNumbers(to catalog: CatalogEntity, serials: [String], completion: @escaping () -> Void) {
        isSaving = true
        errorMessage = nil
        
        var updatedCatalog = catalog
        var currentProducts = updatedCatalog.productIds ?? []
        currentProducts.append(contentsOf: serials)
        updatedCatalog.productIds = currentProducts
        
        Task {
            do {
                try await catalogService.updateCatalog(updatedCatalog)
                SystemLogService.shared.logAction(category: .inventory, severity: .info, message: "Added \(serials.count) serial numbers to catalog \(catalog.name) (\(catalog.catalogId))")
                await MainActor.run {
                    if let index = self.catalogs.firstIndex(where: { $0.id == updatedCatalog.id }) {
                        self.catalogs[index] = updatedCatalog
                    }
                    self.isSaving = false
                    completion()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to add products: \(error.localizedDescription)"
                    self.isSaving = false
                }
            }
        }
    }
    
    func removeSerialNumbers(from catalog: CatalogEntity, at offsets: IndexSet) {
        guard let currentProducts = catalog.productIds else { return }
        
        var updatedProducts = currentProducts
        updatedProducts.remove(atOffsets: offsets)
        
        var updatedCatalog = catalog
        updatedCatalog.productIds = updatedProducts
        
        Task {
            do {
                try await catalogService.updateCatalog(updatedCatalog)
                SystemLogService.shared.logAction(category: .inventory, severity: .warning, message: "Removed \(offsets.count) serial numbers from catalog \(catalog.name) (\(catalog.catalogId))")
                await MainActor.run {
                    if let index = self.catalogs.firstIndex(where: { $0.id == updatedCatalog.id }) {
                        self.catalogs[index] = updatedCatalog
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to remove products: \(error.localizedDescription)"
                }
            }
        }
    }

    func removeImage(at index: Int, from catalog: CatalogEntity) {
        var updatedCatalog = catalog
        var images = updatedCatalog.productImages ?? []
        guard index >= 0 && index < images.count else { return }
        
        images.remove(at: index)
        updatedCatalog.productImages = images
        
        Task {
            do {
                try await catalogService.updateCatalog(updatedCatalog)
                await MainActor.run {
                    if let idx = self.catalogs.firstIndex(where: { $0.id == updatedCatalog.id }) {
                        self.catalogs[idx] = updatedCatalog
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to remove image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func resetForm() {
        newName = ""
        newDescription = ""
        newBrand = ""
        newCategory = .watches
        newAmount = ""
        newBarCode = ""
        newStatus = .active
        existingImageURLs = []
        selectedPhotoItems = []
        selectedImagesData = []
    }
    
    func removeExistingImage(at index: Int) {
        guard index >= 0 && index < existingImageURLs.count else { return }
        existingImageURLs.remove(at: index)
    }
    
    func removeSelectedImage(at index: Int) {
        guard index >= 0 && index < selectedImagesData.count else { return }
        selectedImagesData.remove(at: index)
        selectedPhotoItems.remove(at: index)
    }
    
    func loadSelectedImages() {
        Task {
            var loadedData: [Data] = []
            for item in selectedPhotoItems {
                if let asset = try? await imagePickerService.loadImage(from: item) {
                    loadedData.append(asset.data)
                }
            }
            await MainActor.run {
                self.selectedImagesData = loadedData
            }
        }
    }
}
