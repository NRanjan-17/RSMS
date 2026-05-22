//
//  ActiveScanView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ActiveScanView: View {
    @State private var viewModel = ActiveScanViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.secondary)
                    }
                    
                    Spacer()
                    
                    Text("RFID Active Session")
                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.gold)
                        .kerning(1)
                    
                    Spacer()
                    
                    Button("Done") {
                        viewModel.completeSession()
                        dismiss()
                    }
                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                ZStack(alignment: .bottom) {
                    QRScannerView(scannerService: viewModel.scannerService)
                        .frame(height: 252)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColors.gold70, style: StrokeStyle(lineWidth: 2, dash: [10, 8]))
                        .frame(height: 164)
                        .padding(.horizontal, 44)
                        .padding(.bottom, 32)
                    
                    VStack(spacing: 6) {
                        Text(viewModel.isPaused ? "Scanner paused" : "Align item barcode within frame")
                            .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(viewModel.isPaused ? "Resume to continue scanning inventory." : "Valid scans update quantity and running total instantly.")
                            .font(AppFonts.sansSerif(size: 11))
                            .foregroundStyle(AppColors.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.background.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Running total")
                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(viewModel.totalScanned) items")
                            .font(AppFonts.sansSerif(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    HStack {
                        Image(systemName: viewModel.isProcessing ? "barcode.viewfinder" : "shippingbox")
                            .foregroundStyle(AppColors.gold)
                        Text(viewModel.isProcessing ? "Updating live stock count..." : "Every successful scan refreshes the count without leaving this screen.")
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.secondary)
                        Spacer()
                    }
                    .padding(14)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                HStack(spacing: 10) {
                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        viewModel.isPaused ? viewModel.startScan() : viewModel.pauseSession()
                    }
                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColors.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Manual Entry") {
                        viewModel.openManualEntry()
                    }
                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.gold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold50, lineWidth: 0.5))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.error)
                        Text(errorMessage)
                            .font(AppFonts.sansSerif(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        StatusBadge(text: "Error", status: .error)
                    }
                    .padding(14)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.error.opacity(0.35), lineWidth: 0.5))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("LIVE FEED")
                        .font(AppFonts.sansSerif(size: 11, weight: .bold))
                        .foregroundStyle(AppColors.blue)
                        .kerning(1.5)
                        .padding(.horizontal, 24)
                    
                    ScrollView(showsIndicators: false) {
                        if viewModel.scannedItems.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(AppColors.gold)
                                Text("No scans yet")
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                Text("Start scanning to see product name, SKU, and quantity updates here.")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 32)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal, 24)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(viewModel.scannedItems) { item in
                                    HStack(spacing: 16) {
                                        Circle()
                                            .fill(AppColors.success)
                                            .frame(width: 8, height: 8)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.productName)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text(item.sku)
                                                .font(AppFonts.sansSerif(size: 10))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("Qty \(item.quantity)")
                                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                                .foregroundStyle(AppColors.gold)
                                            Text(item.barcode)
                                                .font(AppFonts.sansSerif(size: 9))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surface)
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: viewModel.isPaused ? "pause.circle" : "antenna.radiowaves.left.and.right")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.gold)
                        .symbolEffect(.variableColor.iterative, options: .repeating, isActive: !viewModel.isPaused)
                    
                    Text(viewModel.isPaused ? "Scanning paused" : "Scanning in progress...")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startScan()
        }
        .onDisappear {
            viewModel.pauseSession()
        }
        .sheet(isPresented: $bindableViewModel.isShowingManualEntry, onDismiss: {
            viewModel.closeManualEntry()
        }) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Manual Entry")
                            .font(AppFonts.serif(size: 28, weight: .semibold))
                            .foregroundStyle(.white)
                        Spacer()
                        Button("Close") {
                            viewModel.closeManualEntry()
                        }
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PRODUCT CODE OR NAME")
                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        TextField(
                            "",
                            text: $bindableViewModel.manualEntryText,
                            prompt: Text("Type product code or name").foregroundStyle(AppColors.tertiary)
                        )
                        .font(AppFonts.sansSerif(size: 15))
                        .foregroundStyle(AppColors.text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 18)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold15, lineWidth: 1)
                        )
                        .onSubmit {
                            viewModel.submitManualEntry()
                        }
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppFonts.sansSerif(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.warning)
                    }
                    
                    HStack(spacing: 10) {
                        Button("Cancel") {
                            viewModel.closeManualEntry()
                        }
                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.gold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold50, lineWidth: 0.5))
                        
                        Button("Confirm") {
                            viewModel.submitManualEntry()
                        }
                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColors.gold)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
            }
            .presentationDetents([.fraction(0.38)])
            .presentationDragIndicator(.visible)
        }
    }
}
