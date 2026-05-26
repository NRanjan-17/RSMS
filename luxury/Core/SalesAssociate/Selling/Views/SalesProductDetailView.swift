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
                                Text("incl. 3% GST")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(.bottom, 14)
                            
                            HStack(spacing: 8) {
                                StatusBadge(text: inStock ? "● In Stock" : "● Out of Stock", status: inStock ? .success : .warning)
                                StatusBadge(text: "Serialized", status: .warning)
                                StatusBadge(text: "RFID", status: .warning)
                            }
                            .padding(.bottom, 16)
                            
                            Text("Oystersteel · Unidirectional rotating bezel · Waterproof to 300m · Triplock crown · Manufacture calibre 3235 · 70-hour power reserve")
                                .font(AppFonts.sansSerif(size: 13, weight: .light))
                                .foregroundStyle(AppColors.secondary)
                                .lineSpacing(6)
                                .padding(.bottom, 20)
                            
                            Text("AI — OFTEN PAIRED WITH")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.8)
                                .padding(.bottom, 11)
                            
                            HStack(spacing: 10) {
                                let pairings = [
                                    ("ROLEX", "Datejust 41", "\(CurrencyManager.shared.symbol)9,20,000"),
                                    ("ROLEX", "GMT-Master II", "\(CurrencyManager.shared.symbol)18,40,000")
                                ]
                                ForEach(pairings, id: \.1) { pair in
                                    VStack(alignment: .leading, spacing: 0) {
                                        ZStack {
                                            Rectangle().fill(AppColors.surface2).frame(height: 56)
                                            Circle().stroke(AppColors.gold.opacity(0.3), lineWidth: 0.6).frame(width: 14, height: 14)
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(pair.0)
                                                .font(AppFonts.sansSerif(size: 9))
                                                .foregroundStyle(AppColors.gold)
                                                .kerning(1)
                                            Text(pair.1)
                                                .font(AppFonts.serif(size: 12, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            Text(pair.2)
                                                .font(AppFonts.serif(size: 13, weight: .semibold))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                    }
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold15, lineWidth: 0.5))
                                }
                            }
                            .padding(.bottom, 32)
                            
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
                                        saAppState.selectedTab = .pos
                                        dismiss()
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
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
