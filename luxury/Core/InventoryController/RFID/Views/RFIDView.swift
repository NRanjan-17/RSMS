//
//  RFIDView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct RFIDView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = RFIDViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "RFID & Barcode")
                
                VStack(spacing: 20) {
                    CustomButton(title: "Start New Scan Session", icon: AnyView(Image(systemName: "antenna.radiowaves.left.and.right")), action: {
                        router.presentFullScreen(ICRoute.activeScan)
                    })
                    
                    Text("Point device at RFID tags, QR, or Barcodes to track")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                }
                .padding(24)
                .background(AppColors.surface)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("RECENT SCAN SESSIONS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.recentSessions) { session in
                                Button(action: { router.presentFullScreen(ICRoute.scanSessionDetail(session)) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(session.zone)
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            Text(session.date)
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("\(session.scannedCount)/\(session.expectedCount)")
                                                .font(AppFonts.sansSerif(size: 15, weight: .semibold))
                                                .foregroundStyle(session.variance == 0 ? AppColors.success : AppColors.error)
                                            Text("Items")
                                                .font(AppFonts.sansSerif(size: 10))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                    }
                                    .padding(16)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
