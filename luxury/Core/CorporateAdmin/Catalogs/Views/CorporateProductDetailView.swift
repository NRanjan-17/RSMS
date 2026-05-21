//
//  ProductDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 21/05/26.
//

import SwiftUI

struct CorporateProductDetailView: View {
    let summary: ProductInventorySummary
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(CatalogsViewModel.self) private var viewModel
    
    @State private var showingDeleteConfirm = false
    
    private var currentSummary: ProductInventorySummary {
        viewModel.products.first(where: { $0.product.id == summary.product.id }) ?? summary
    }
    
    private var currentProduct: ProductEntity {
        currentSummary.product
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentProduct.name)
                        .font(AppFonts.serif(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.text)
                    
                    HStack {
                        Text(currentProduct.brand)
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                            .kerning(1.5)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Product Details") {
                LabeledContent("Category", value: currentProduct.category)
                if let collection = currentProduct.collection, !collection.isEmpty {
                    LabeledContent("Collection", value: collection)
                }
                if !currentProduct.description.isEmpty {
                    LabeledContent("Description", value: currentProduct.description)
                }
                LabeledContent("Total Stock", value: "\(currentSummary.totalQuantity)")
                LabeledContent("Unit Price", value: String(format: "₹%.2f", currentProduct.amount))
                LabeledContent("Barcode", value: currentProduct.barCode)
            }
            
            Section("Inventory Breakdown") {
                if currentSummary.locations.isEmpty {
                    Text("No stock available in any boutique")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                } else {
                    ForEach(currentSummary.locations) { location in
                        HStack {
                            Text(location.storeName)
                                .font(AppFonts.sansSerif(size: 15))
                            Spacer()
                            Text("\(location.quantity)")
                                .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                .foregroundStyle(location.quantity > 0 ? AppColors.success : AppColors.error)
                        }
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    showingDeleteConfirm = true
                }) {
                    Text("Delete Product")
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    router.push(CARoute.productForm(editProduct: currentProduct))
                }
                .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.gold)
            }
        }
        .alert("Delete Product", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteProduct(currentProduct) {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this product? This action cannot be undone.")
        }
    }
}

