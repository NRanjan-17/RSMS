//
//  NewTransferView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct NewTransferView: View {
    @State private var viewModel = NewTransferViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text("New Transfer Request")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SOURCE")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.tertiary)
                                    Text(viewModel.sourceStore)
                                        .font(AppFonts.serif(size: 18))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Image(systemName: "building.2")
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Image(systemName: "arrow.down")
                                .foregroundStyle(AppColors.tertiary)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DESTINATION")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.tertiary)
                                    Text(viewModel.destinationStore)
                                        .font(AppFonts.serif(size: 18))
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("ITEMS TO TRANSFER")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                Spacer()
                                Button("+ Add Item") {
                                }
                                .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(viewModel.items) { item in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(item.name)
                                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                    .foregroundStyle(.white)
                                                Text(item.sku)
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.tertiary)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 16) {
                                                Button(action: {
                                                    viewModel.decrementQty(for: item.id)
                                                }) {
                                                    Image(systemName: "minus.circle")
                                                        .foregroundStyle(AppColors.secondary)
                                                }
                                                
                                                Text("\(item.qty)")
                                                    .font(AppFonts.serif(size: 18, weight: .bold))
                                                    .foregroundStyle(AppColors.gold)
                                                    .frame(width: 24)
                                                
                                                Button(action: {
                                                    viewModel.incrementQty(for: item.id)
                                                }) {
                                                    Image(systemName: "plus.circle.fill")
                                                        .foregroundStyle(AppColors.gold)
                                                }
                                            }
                                        }
                                        
                                        if item.qty > item.availableQty {
                                            Text("Insufficient stock. Only \(item.availableQty) units available.")
                                                .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                                .foregroundStyle(AppColors.error)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 16)
                                    .background(AppColors.surface)
                                }
                            }
                        }
                        
                        HStack(spacing: 10) {
                            StatusBadge(text: viewModel.approvalState.rawValue, status: viewModel.approvalState == .approved ? .success : .pending)
                            StatusBadge(text: viewModel.packingSlipGenerated ? "Packing Slip Ready" : "ASN Match Pending", status: viewModel.packingSlipGenerated ? .success : .neutral)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 8)
                }
                
                VStack {
                    HStack(spacing: 10) {
                        CustomOutlineButton(title: "Approve Mock", action: { viewModel.approve() })
                        CustomButton(title: "Submit Request", action: {
                            viewModel.submit()
                            viewModel.completeSession()
                            dismiss()
                        })
                        .disabled(viewModel.hasStockError)
                    }
                        .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
