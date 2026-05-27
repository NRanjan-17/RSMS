//
//  PurchaseDetailsView.swift
//  luxury
//
//  Created by Antigravity on 26/05/26.
//

import SwiftUI

struct PurchaseDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    
    let client: Client
    let purchase: ClientPurchase
    
    private var warrantyInfo: (isActive: Bool, expirationText: String) {
        return (isActive: true, expirationText: "Valid until 24 nov 2026")
    }
    
    private var category: String {
        let lower = purchase.name.lowercased()
        if lower.contains("watch") || lower.contains("rolex") || lower.contains("patek") || lower.contains("ap") || lower.contains("omega") {
            return "Timepieces"
        } else if lower.contains("bag") || lower.contains("pouch") || lower.contains("birkin") || lower.contains("classic flap") || lower.contains("neverfull") {
            return "Leather Goods"
        } else if lower.contains("bracelet") || lower.contains("ring") || lower.contains("diamond") || lower.contains("gold") {
            return "Fine Jewelry"
        } else {
            return "Accessories"
        }
    }
    
    private var productId: String {
        return "PRD-" + String(purchase.id.uuidString.prefix(8).uppercased())
    }
    
    private var brand: String {
        let parts = purchase.name.components(separatedBy: " ")
        if let first = parts.first, !first.isEmpty {
            return first
        }
        return "Maison"
    }
    
    private var productNameOnly: String {
        let parts = purchase.name.components(separatedBy: " ")
        if parts.count > 1 {
            return parts.dropFirst().joined(separator: " ")
        }
        return purchase.name
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header navigation
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 44, height: 44)
                    }
                    Text("Purchase Details")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Spacer().frame(height: 8)
                        
                        // PRODUCT DETAILS enclosed card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Product ID")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(productId)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Brand")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(brand)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Product Name")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(productNameOnly)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Product Category")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(category)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            Text("PRODUCT DETAILS")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 8)
                                .background(AppColors.surface)
                                .offset(x: 16, y: -8)
                        }
                        
                        // BOUTIQUE DETAILS enclosed card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Boutique ID")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text("BTQ-MUM-01")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Boutique Name")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text("Maison Mumbai")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Location")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text("Taj Mahal Palace, Mumbai")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            Text("BOUTIQUE DETAILS")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 8)
                                .background(AppColors.surface)
                                .offset(x: 16, y: -8)
                        }
                        
                        // ORDER DETAILS enclosed card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Date of Purchase")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(purchase.date)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Amount Paid")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(CurrencyManager.shared.format(amount: purchase.price))
                                    .font(AppFonts.serif(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            Text("ORDER DETAILS")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 8)
                                .background(AppColors.surface)
                                .offset(x: 16, y: -8)
                        }
                        
                        // Glassmorphic Warranty status card
                        let wInfo = warrantyInfo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WARRANTY")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(Color(hex: 0xA3E4D7))
                                .kerning(1.5)
                            
                            HStack(spacing: 8) {
                                Text("ACTIVE")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(hex: 0x3D9E6A).opacity(0.6))
                                    )
                                
                                Text(wInfo.expirationText.uppercased())
                                    .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack {
                                Color(hex: 0x3D9E6A).opacity(0.12)
                                Color.clear.background(.ultraThinMaterial)
                                LinearGradient(
                                    colors: [.white.opacity(0.18), .white.opacity(0.02), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: 0x3D9E6A).opacity(0.8),
                                            Color(hex: 0x3D9E6A).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: Color(hex: 0x3D9E6A).opacity(0.25),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        
                        Spacer().frame(height: 10)
                        
                        // Bottom conditional Action Button
                        if wInfo.isActive {
                            Button(action: {
                                // Navigate to after-sales intake pre-filled
                                router.push(SARoute.afterSalesIntake(client: client, serialNumber: productId, isWarrantyActive: wInfo.isActive))
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "wrench.and.screwdriver")
                                    Text("Create Ticket")
                                }
                                .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppColors.gold)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text("Warranty Expired - Ticket Cannot Be Created")
                                .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.05))
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
