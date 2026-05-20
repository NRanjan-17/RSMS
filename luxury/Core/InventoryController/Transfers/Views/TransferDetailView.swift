//
//  TransferDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct TransferDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let transfer: TransferRequest
    
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
                    Text("Transfer Request")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(transfer.reference)
                                    .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(1.5)
                                Spacer()
                                StatusBadge(text: transfer.status, status: transfer.badgeStatus)
                            }
                            
                            Text("Inter-store Movement")
                                .font(AppFonts.serif(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.tertiary).frame(width: 8, height: 8)
                                Text("FROM: \(transfer.source)")
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(AppColors.text)
                            }
                            Rectangle().fill(AppColors.gold15).frame(width: 1, height: 20).padding(.leading, 3.5)
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.gold).frame(width: 8, height: 8)
                                Text("TO: \(transfer.destination)")
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(AppColors.text)
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ITEMS (\(transfer.itemCount))")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(transfer.items) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text(item.sku)
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        Spacer()
                                        Text("×\(item.qty)")
                                            .font(AppFonts.serif(size: 18, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(AppColors.surface)
                                }
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
