//
//  ActiveScanView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 22/05/26.
//

import SwiftUI

struct BarcodeScanView: View {
    @State private var viewModel = BarcodeScanViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text("Scan")
                        .font(AppFonts.serif(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                // Scanner Area
                ZStack {
                    if viewModel.isScanning {
                        QRScannerView { code in
                            viewModel.lookupBarcode(code)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 24)
                        
                        // Scanner Overlay Guide
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(AppColors.gold.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [10]))
                            .padding(.horizontal, 24)
                    }
                    
                    // Loading State
                    if viewModel.isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(AppColors.gold)
                                .scaleEffect(1.5)
                            Text("Fetching Live Stock...")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 24)
                    }
                }
                .frame(maxHeight: 400)
                
                // Results Area
                VStack {
                    if let error = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.error)
                            
                            Text(error)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.error)
                                .multilineTextAlignment(.center)
                            
                            Button("Scan Again") {
                                viewModel.resetScanner()
                            }
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                        }
                        .padding(24)
                    } else if let summary = viewModel.scannedProduct {
                        // Product Details
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(summary.product.brand.uppercased())
                                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                        .kerning(1)
                                    
                                    Text(summary.product.name)
                                        .font(AppFonts.serif(size: 22, weight: .bold))
                                        .foregroundStyle(.white)
                                    
                                    Text(summary.product.productId)
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(summary.totalQuantity)")
                                        .font(AppFonts.sansSerif(size: 32, weight: .bold))
                                        .foregroundStyle(summary.totalQuantity > 0 ? .white : AppColors.error)
                                    Text("IN STOCK")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                }
                            }
                            
                            Divider().background(AppColors.surface)
                            
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 12) {
                                    ForEach(summary.locations) { location in
                                        HStack {
                                            Text(location.storeName)
                                                .font(AppFonts.sansSerif(size: 14))
                                                .foregroundStyle(.white)
                                            Spacer()
                                            Text("\(location.quantity)")
                                                .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                                .foregroundStyle(location.quantity > 0 ? .white : AppColors.secondary)
                                        }
                                    }
                                }
                            }
                            
                            Button(action: {
                                viewModel.resetScanner()
                            }) {
                                Text("Scan Another Item")
                                    .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                    .foregroundStyle(AppColors.background)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(AppColors.gold)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface2)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(24)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 40))
                                .foregroundStyle(AppColors.secondary)
                            Text("Position barcode within the frame")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                        }
                        .padding(.top, 40)
                    }
                }
                
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}
