//
//  BarcodeLookupView.swift
//  luxury
//

import SwiftUI

struct BarcodeLookupView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = BarcodeLookupViewModel()
    @State private var scannerService = ScannerService()
    @State private var manualEntry: String = ""
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Barcode Lookup", showBackButton: true, backAction: {
                    router.pop()
                })
                
                // Camera View
                ZStack {
                    QRScannerView(scannerService: scannerService)
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding()
                    
                    // Center Targeting Box
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.gold, lineWidth: 2)
                        .frame(width: 200, height: 200)
                }
                
                // Manual Entry
                HStack {
                    TextField("Enter Barcode Manually...", text: $manualEntry)
                        .font(AppFonts.sansSerif(size: 16))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled(true)
                        .submitLabel(.search)
                        .padding(12)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onSubmit {
                            viewModel.lookupItem(by: manualEntry)
                        }
                    
                    Button(action: {
                        viewModel.lookupItem(by: manualEntry)
                    }) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(AppFonts.sansSerif(size: 32))
                            .foregroundStyle(manualEntry.isEmpty ? AppColors.tertiary : AppColors.gold)
                    }
                    .disabled(manualEntry.isEmpty)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(AppColors.gold)
                                .padding(.top, 40)
                        } else if let error = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(AppFonts.sansSerif(size: 32))
                                    .foregroundStyle(AppColors.error)
                                Text(error)
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(.top, 40)
                        } else if let item = viewModel.scannedItem {
                            // Results View
                            VStack(spacing: 20) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.brand)
                                            .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                            .kerning(1.5)
                                            .textCase(.uppercase)
                                        
                                        Text(item.name)
                                            .font(AppFonts.serif(size: 22, weight: .medium))
                                            .foregroundStyle(AppColors.text)
                                        
                                        Text("UPC: \(item.barCode)")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("\(viewModel.liveStockCount)")
                                            .font(AppFonts.serif(size: 36, weight: .bold))
                                            .foregroundStyle(viewModel.liveStockCount > 0 ? AppColors.success : AppColors.error)
                                        Text("In Stock")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                }
                                
                                Divider().background(AppColors.surface)
                                
                                HStack {
                                    Text("Category")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(item.category.rawValue.capitalized)
                                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.text)
                                }
                                
                                HStack {
                                    Text("Price")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text("\(CurrencyManager.shared.symbol)\(String(format: "%.2f", item.amount))")
                                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.text)
                                }
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.surface2, lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 10)
                        } else {
                            // Initial State
                            VStack(spacing: 12) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(AppFonts.sansSerif(size: 32))
                                    .foregroundStyle(AppColors.tertiary)
                                Text("Scan a barcode to see live stock details")
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(.top, 40)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            scannerService.onScannedCode = { code in
                scannerService.playSuccessFeedback()
                viewModel.lookupItem(by: code)
            }
        }
    }
}
