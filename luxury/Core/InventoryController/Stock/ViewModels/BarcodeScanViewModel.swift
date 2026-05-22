//
//  ActiveScanViewModel.swift
//  luxury
//
//  Created by Nalinish Ranjan on 22/05/26.
//

import Foundation
import Observation
import Supabase
import PostgREST

@Observable
final class BarcodeScanViewModel {
    var scannedProduct: ProductInventorySummary?
    var isLoading = false
    var errorMessage: String?
    
    var isScanning = true
    
    let scannerService = ScannerService()
    
    private let client = SupabaseManager.shared.client
    
    init() {
        scannerService.onScannedCode = { [weak self] code in
            Task { @MainActor in
                self?.lookupBarcode(code)
            }
        }
    }
    
    func lookupBarcode(_ barcode: String) {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        isScanning = false // Pause scanning while we look up
        
        Task {
            do {
                // 1. Find product by barcode
                let productsResponse: [ProductEntity] = try await client.from("products")
                    .select()
                    .eq("bar_code", value: barcode)
                    .execute()
                    .value
                
                guard let product = productsResponse.first else {
                    await MainActor.run {
                        self.errorMessage = "No product found for barcode: \(barcode)"
                        self.isLoading = false
                    }
                    return
                }
                
                // 2. Fetch inventory for this product
                let inventoryResponse: [InventoryItem] = try await client.from("inventory")
                    .select()
                    .eq("sku_id", value: product.id.uuidString)
                    .execute()
                    .value
                
                // 3. Fetch boutiques to resolve store names
                let boutiquesResponse: [CorporateBoutique] = try await client.from("boutiques").select().execute().value
                
                var locations: [LocationInventoryDetail] = []
                var totalQty = 0
                
                for item in inventoryResponse {
                    totalQty += item.quantity
                    let storeName = boutiquesResponse.first(where: { $0.id == item.storeId })?.name ?? "Unknown Location"
                    
                    locations.append(LocationInventoryDetail(
                        storeId: item.storeId,
                        storeName: storeName,
                        quantity: item.quantity,
                        isAvailable: item.productAvailable
                    ))
                }
                
                let summary = ProductInventorySummary(
                    product: product,
                    totalQuantity: totalQty,
                    locations: locations.sorted(by: { $0.storeName < $1.storeName })
                )
                
                await MainActor.run {
                    self.scannedProduct = summary
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to fetch live stock: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func resetScanner() {
        scannedProduct = nil
        errorMessage = nil
        isScanning = true
    }
}
