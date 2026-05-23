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
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        viewModel.pauseAndSaveSession()
                        dismiss()
                    }) {
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
                
                VStack(spacing: 12) {
                    HStack {
                        Text("\(viewModel.totalScanned) of \(viewModel.totalExpected) items found")
                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(Int(viewModel.progress * 100))%")
                            .font(AppFonts.sansSerif(size: 13, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.surface)
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(AppColors.gold)
                                .frame(width: geo.size.width * viewModel.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                
                if viewModel.show24hWarning {
                    VStack(spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(AppColors.warning)
                                .font(.system(size: 20))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Session paused for over 24 hours. Please verify counts before resuming.")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        
                        Button(action: {
                            viewModel.show24hWarning = false
                        }) {
                            Text("Acknowledge & Resume")
                                .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(AppColors.gold)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(16)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.warning.opacity(0.35), lineWidth: 0.5))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
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
                    .disabled(viewModel.show24hWarning)
                    
                    Button("Manual SKU") {
                        viewModel.recordScan(epc: "MANUAL-SKU-001", name: "Manual SKU exception", ok: false)
                    }
                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                    .foregroundStyle(AppColors.gold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold50, lineWidth: 0.5))
                    .disabled(viewModel.show24hWarning)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                if viewModel.duplicateDetected || viewModel.unknownItemDetected {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.error)
                        Text(viewModel.duplicateDetected ? "Duplicate scan confirmation required" : "Unknown item exception opened")
                            .font(AppFonts.sansSerif(size: 12, weight: .medium))
                            .foregroundStyle(.white)
                        Spacer()
                        StatusBadge(text: "Exception", status: .error)
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
                        VStack(spacing: 1) {
                            ForEach(viewModel.scannedTags) { tag in
                                HStack(spacing: 16) {
                                    Circle()
                                        .fill(tag.ok ? AppColors.success : AppColors.error)
                                        .frame(width: 8, height: 8)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(tag.name)
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(tag.ok ? .white : AppColors.error)
                                        Text(tag.epc)
                                            .font(AppFonts.sansSerif(size: 10))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    
                                    Spacer()
                                    
                                    if tag.ok {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.success)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(AppColors.surface)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.gold)
                        .symbolEffect(.variableColor.iterative, options: .repeating)
                    
                    Text("Scanning in progress...")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.checkAndRestoreSession()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background || newPhase == .inactive {
                viewModel.pauseAndSaveSession()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.pauseAndSaveSession()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            viewModel.pauseAndSaveSession()
        }
    }
}
