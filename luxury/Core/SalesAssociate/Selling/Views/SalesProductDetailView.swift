//
//  ProductDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct SalesProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SalesAssociateAppState.self) private var saAppState
    let catalog: CatalogEntity
    
    @State private var showToast = false
    
    var inStock: Bool {
        ((catalog.productIds?.count ?? 0) - (catalog.reserved?.count ?? 0)) > 0
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Catalog")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        ProductImageGalleryView(imageUrls: catalog.productImages)
                            .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(catalog.brand.uppercased())
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                                .padding(.bottom, 6)
                            
                            Text(catalog.name)
                                .font(AppFonts.serif(size: 26, weight: .medium))
                                .foregroundStyle(AppColors.text)
                                .lineSpacing(4)
                                .padding(.bottom, 10)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(CurrencyManager.shared.format(amount: catalog.amount))
                                    .font(AppFonts.serif(size: 30, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding(.bottom, 14)
                            
                            HStack(spacing: 8) {
                                StatusBadge(text: inStock ? "● In Stock" : "● Out of Stock", status: inStock ? .success : .warning)
                            }
                            .padding(.bottom, 16)
                            
                            if !catalog.description.isEmpty {
                                Text(catalog.description)
                                    .font(AppFonts.sansSerif(size: 13, weight: .light))
                                    .foregroundStyle(AppColors.secondary)
                                    .lineSpacing(6)
                                    .padding(.bottom, 32)
                            }
                            
                            VStack(spacing: 0) {
                                Divider().background(AppColors.gold15).padding(.bottom, 12)
                                CustomButton(
                                    title: "Add to Cart",
                                    icon: AnyView(Image(systemName: "cart.badge.plus").font(.system(size: 14, weight: .semibold))),
                                    action: { 
                                        let item = CatalogItem(
                                            id: catalog.id,
                                            catalogId: catalog.catalogId,
                                            name: catalog.name,
                                            description: catalog.description,
                                            brand: catalog.brand,
                                            category: catalog.category.rawValue,
                                            amount: catalog.amount,
                                            barCode: catalog.barCode,
                                            status: catalog.status.rawValue,
                                            reserved: catalog.reserved,
                                            productIds: catalog.productIds,
                                            createdAt: nil,
                                            productImages: catalog.productImages
                                        )
                                        POSViewModel.shared.addToCart(item)
                                        withAnimation(.spring()) {
                                            showToast = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation(.spring()) {
                                                showToast = false
                                            }
                                        }
                                    }
                                )
                                .padding(.bottom, 40)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                    }
                }
            }
            
            if showToast {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppColors.success)
                        Text("Added to Cart")
                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(AppColors.surface2)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    .padding(.bottom, 60)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
