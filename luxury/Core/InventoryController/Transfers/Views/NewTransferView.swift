//
//  NewTransferView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct NewTransferView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = NewTransferViewModel()
    @State private var showSearchSheet = false
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
                        // Source & Destination
                        VStack(spacing: 8) {
                            // Source
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SOURCE")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                        .kerning(1.5)
                                    
                                    Menu {
                                        ForEach(viewModel.availableBoutiques) { boutique in
                                            Button(boutique.name) { viewModel.sourceStore = boutique }
                                        }
                                    } label: {
                                        HStack {
                                            Text(viewModel.sourceStore?.name ?? "Select Source")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(viewModel.sourceStore == nil ? AppColors.tertiary : .white)
                                                .lineLimit(1)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 10))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                Image(systemName: "building.2")
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding()
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Image(systemName: "arrow.down")
                                .foregroundStyle(AppColors.tertiary)
                                .padding(.vertical, 4)
                            
                            // Destination
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("DESTINATION")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                        .kerning(1.5)
                                    
                                    Menu {
                                        Button("Select Destination") { viewModel.destinationStore = nil }
                                        ForEach(viewModel.availableBoutiques) { boutique in
                                            Button(boutique.name) { viewModel.destinationStore = boutique }
                                        }
                                    } label: {
                                        HStack {
                                            Text(viewModel.destinationStore?.name ?? "Select Destination")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(viewModel.destinationStore == nil ? AppColors.tertiary : .white)
                                                .lineLimit(1)
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.system(size: 10))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                Image(systemName: "building.2")
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding()
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
                                    showSearchSheet = true
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
                        CustomButton(title: "Submit Request", action: {
                            viewModel.submit()
                            viewModel.completeSession()
                            dismiss()
                        })
                        .disabled(viewModel.hasStockError || viewModel.destinationStore == nil)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.fetchBoutiques()
        }
        .sheet(isPresented: $showSearchSheet) {
            TransferItemSearchSheet { selectedItem in
                viewModel.addItem(selectedItem)
            }
        }
        .alert(
            "Stock Limit Reached",
            isPresented: Binding(
                get: { viewModel.showAlert },
                set: { viewModel.showAlert = $0 }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
}
