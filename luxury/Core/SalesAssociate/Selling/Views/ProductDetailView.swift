//
//  ProductDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let product: Product
    
    init(product: Product = Product(brand: "Rolex", name: "Submariner Date", price: "₹14,50,000", inStock: true)) {
        self.product = product
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
                        ZStack {
                            Rectangle()
                                .fill(AppColors.surface)
                                .frame(height: 240)
                                .overlay(
                                    VStack {
                                        Rectangle().fill(AppColors.gold15).frame(height: 0.5)
                                        Spacer()
                                        Rectangle().fill(AppColors.gold15).frame(height: 0.5)
                                    }
                                )
                            
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle().stroke(AppColors.gold.opacity(0.25), lineWidth: 0.8).frame(width: 56, height: 56)
                                    Circle().stroke(AppColors.gold.opacity(0.2), lineWidth: 0.5).frame(width: 44, height: 44)
                                    Circle().fill(AppColors.gold.opacity(0.45)).frame(width: 6, height: 6)
                                    Image(systemName: "clock")
                                        .font(.system(size: 24))
                                        .foregroundStyle(AppColors.gold.opacity(0.55))
                                }
                                Text("PRODUCT IMAGE")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.tertiary)
                                    .kerning(2)
                            }
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(product.brand.uppercased())
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                                .padding(.bottom, 6)
                            
                            Text(product.name)
                                .font(AppFonts.serif(size: 26, weight: .medium))
                                .foregroundStyle(AppColors.text)
                                .lineSpacing(4)
                                .padding(.bottom, 10)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(product.price)
                                    .font(AppFonts.serif(size: 30, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                                Text("incl. 3% GST")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(.bottom, 14)
                            
                            HStack(spacing: 8) {
                                StatusBadge(text: product.inStock ? "● In Stock" : "● Out of Stock", status: product.inStock ? .success : .warning)
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
                                    ("ROLEX", "Datejust 41", "₹9,20,000"),
                                    ("ROLEX", "GMT-Master II", "₹18,40,000")
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
                                    action: { dismiss() }
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
    }
}
