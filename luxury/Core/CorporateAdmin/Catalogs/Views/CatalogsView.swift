//
//  CatalogsView.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import SwiftUI

struct CatalogsView: View {
    @Environment(Router.self) private var router
    @Environment(CatalogsViewModel.self) private var viewModel
    
    var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    // Placeholder for alignment
                    Color.clear.frame(width: 44, height: 44)
                    
                    Spacer()
                    
                    Text("Catalogs")
                        .font(AppFonts.serif(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    // Add Button in top right
                    Button(action: {
                        router.push(CARoute.productForm(editProduct: nil))
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColors.secondary)
                    TextField("Search catalog...", text: $bindableViewModel.searchText)
                        .font(AppFonts.sansSerif(size: 15))
                        .foregroundStyle(.white)
                        .tint(AppColors.gold)
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: { viewModel.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppColors.secondary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(AppColors.gold)
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text(errorMessage)
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Retry") {
                        viewModel.fetchData()
                    }
                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                    .padding(.top, 16)
                    Spacer()
                } else if viewModel.filteredProducts.isEmpty {
                    Spacer()
                    Image(systemName: "box.truck.badge.clock.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.secondary)
                        .padding(.bottom, 16)
                    Text(viewModel.searchText.isEmpty ? "No products found in catalog." : "No matching products.")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredProducts) { product in
                                Button(action: {
                                    router.push(CARoute.productDetail(product))
                                }) {
                                    CatalogItemRow(product: product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct CatalogItemRow: View {
    let product: ProductEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(AppFonts.serif(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.text)
                    Text(product.brand)
                        .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                        .kerning(1.2)
                }
                
                Spacer()
                
                Text(String(format: "$%.2f", product.amount))
                    .font(AppFonts.sansSerif(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.text)
            }
            
            Divider().background(AppColors.border)
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(AppColors.secondary)
                    Text(product.category.rawValue)
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(product.availableStock > 0 ? AppColors.success : AppColors.error)
                    Text("\(product.availableStock) in stock")
                        .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                        .foregroundStyle(product.availableStock > 0 ? AppColors.success : AppColors.error)
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.gold15, lineWidth: 1)
        )
    }
}
