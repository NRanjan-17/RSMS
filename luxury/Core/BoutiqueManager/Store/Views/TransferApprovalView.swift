//
//  TransferApprovalView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct TransferApprovalView: View {
    @Environment(\.dismiss) private var dismiss
    
    let transfer = TransferRequest(
        source: "DLF Emporio, Delhi",
        destination: "Current Store",
        items: [
            TransferItem(sku: "WAT-H-001", name: "Heritage Watch 42mm", qty: 2),
            TransferItem(sku: "LTH-B-052", name: "Leather Tote Black", qty: 5)
        ],
        status: "Pending Approval"
    )
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                CustomHeader(title: "Transfer Details")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.secondary).frame(width: 8, height: 8)
                                Text("From: \(transfer.source)")
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.text)
                            }
                            
                            Rectangle().fill(AppColors.border).frame(width: 1, height: 20).padding(.leading, 3.5)
                            
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.gold).frame(width: 8, height: 8)
                                Text("To: \(transfer.destination)")
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.text)
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Items Requested (\(transfer.items.count))")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .textCase(.uppercase)
                            
                            ForEach(transfer.items) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.name)
                                            .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                            .foregroundStyle(AppColors.text)
                                        Text(item.sku)
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    Text("Qty: \(item.qty)")
                                        .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                .padding(.vertical, 8)
                                if item.id != transfer.items.last?.id {
                                    Divider().background(AppColors.border)
                                }
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Spacer(minLength: 40)
                        
                        HStack(spacing: 12) {
                            Button(action: { dismiss() }) {
                                Text("Reject Request")
                                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.error)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.error.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Approve Transfer")
                                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(AppColors.gold)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
