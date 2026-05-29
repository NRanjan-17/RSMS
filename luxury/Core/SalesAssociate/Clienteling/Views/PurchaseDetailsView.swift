//
//  PurchaseDetailsView.swift
//  luxury
//
//  Created by Antigravity on 26/05/26.
//

import SwiftUI
import Supabase

struct PurchasedItemDetails: Codable {
    let id: UUID
    let uid: UUID
    let clientId: UUID?
    let productId: UUID
    let transactionId: String
    let status: String
    let reservedDate: Date?
    let deliveryDate: Date?
    let boutiqueId: UUID?
    let staffId: UUID?
    let catalogs: CatalogEntity?
    let staff: StaffDetails?
    
    struct StaffDetails: Codable {
        let id: UUID
        let name: String
        let email: String
        let role: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, uid, status
        case clientId = "client_id"
        case productId = "product_id"
        case transactionId = "transaction_id"
        case reservedDate = "reserved_date"
        case deliveryDate = "delivery_date"
        case boutiqueId = "boutique_id"
        case staffId = "staff_id"
        case catalogs
        case staff
    }
}

struct PurchaseDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    
    let client: Client
    let purchase: ClientPurchase
    
    @State private var details: PurchasedItemDetails? = nil
    
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
    
    private var displayProductId: String {
        return details?.catalogs?.id.uuidString ?? purchase.id.uuidString
    }
    
    private var displayProductSerial: String {
        return details?.catalogs?.catalogId ?? ("PRD-" + String(purchase.id.uuidString.prefix(8).uppercased()))
    }
    
    private var displayBrand: String {
        return details?.catalogs?.brand ?? brand
    }
    
    private var displayProductName: String {
        return details?.catalogs?.name ?? productNameOnly
    }
    
    private var displayCategory: String {
        return details?.catalogs?.category.rawValue ?? category
    }
    
    private var displayTransactionId: String {
        return details?.transactionId ?? "TX-UNKNOWN"
    }
    
    private var displayAdvisorName: String {
        return details?.staff?.name ?? "Arjun Singh"
    }
    
    private var displayAdvisorId: String {
        return details?.staff?.id.uuidString ?? "Unknown Advisor"
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header navigation
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
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
                                Text(displayProductId)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Product Serial Number")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayProductSerial)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Brand")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayBrand)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Product Name")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayProductName)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Product Category")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayCategory)
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
                        
                        // STAFF / ADVISOR Section enclosed card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Served By")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayAdvisorName)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Advisor ID")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayAdvisorId)
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
                            Text("STAFF / ADVISOR")
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
                            Divider().background(AppColors.border)
                            
                            HStack {
                                Text("Transaction ID")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(displayTransactionId)
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
                            Text("ORDER DETAILS")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 8)
                                .background(AppColors.surface)
                                .offset(x: 16, y: -8)
                        }
                        
                        Button(action: {
                            router.push(SARoute.afterSalesIntake(client: client, serialNumber: displayProductSerial, isWarrantyActive: true, purchaseId: purchase.id))
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text("Report Issue")
                            }
                            .font(AppFonts.sansSerif(size: 15, weight: .bold))
                            .foregroundStyle(AppColors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppColors.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.top, 8)

                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            loadDetails()
        }
    }
    
    private func loadDetails() {
        Task {
            do {
                let fetched: [PurchasedItemDetails] = try await SupabaseManager.shared.client
                    .from("purchased_items")
                    .select("*, catalogs(*), staff(*)")
                    .eq("id", value: purchase.id.uuidString)
                    .execute()
                    .value
                
                if let first = fetched.first {
                    await MainActor.run {
                        self.details = first
                    }
                }
            } catch {
                print("Supabase fetch purchased item detail warning: \(error)")
            }
        }
    }
}
