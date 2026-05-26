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
                            .font(.system(size: 32))
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
                                    .font(.system(size: 32))
                                    .foregroundStyle(AppColors.error)
                                Text(error)
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(.top, 40)
                        } else {
                            // Initial State
                            VStack(spacing: 12) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 32))
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
            viewModel.scannedItem = nil
            scannerService.onScannedCode = { code in
                scannerService.playSuccessFeedback()
                viewModel.lookupItem(by: code)
            }
        }
        .onChange(of: viewModel.scannedItem) { old, newItem in
            if let item = newItem {
                router.push(ICRoute.catalogDetail(item, viewModel.liveStockCount))
            }
        }
    }
}
