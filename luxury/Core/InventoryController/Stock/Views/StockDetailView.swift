//
//  StockDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct StockDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let alert: InventoryAlert
    
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
                    Text("Inventory Details")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(alert.sku)
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            Text(alert.itemName)
                                .font(AppFonts.serif(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .lineSpacing(4)
                            
                            StatusBadge(text: alert.currentQty == 0 ? "Out of Stock" : "\(alert.currentQty) In Boutique", status: alert.status)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 1) {
                            DetailInfoRow(label: "Available", value: "\(alert.currentQty)")
                            DetailInfoRow(label: "Reserved", value: "2")
                            DetailInfoRow(label: "In Transit", value: "12")
                            DetailInfoRow(label: "Last Count", value: "14 May 2026")
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RECENT MOVEMENTS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                MovementRow(type: "Sale", qty: "-1", date: "Today, 11:45 AM")
                                MovementRow(type: "Transfer In", qty: "+12", date: "Yesterday, 04:20 PM")
                                MovementRow(type: "Count Adjustment", qty: "-2", date: "12 May 2026")
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct DetailInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.sansSerif(size: 13))
                .foregroundStyle(AppColors.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.surface)
    }
}

private struct MovementRow: View {
    let type: String
    let qty: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(type)
                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Text(date)
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.tertiary)
            }
            Spacer()
            Text(qty)
                .font(AppFonts.serif(size: 18, weight: .bold))
                .foregroundStyle(qty.hasPrefix("+") ? AppColors.success : AppColors.error)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.surface)
    }
}
