//
//  StoreView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct StoreView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = StoreViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Store Operations")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PENDING APPROVALS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                Button(action: { router.presentFullScreen(BMRoute.transferApproval) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Stock Transfers")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("\(viewModel.pendingTransfersCount) Requests awaiting approval")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: { router.push(BMRoute.endlessAisleRequests) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Endless Aisle Requests")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("Review and authorize boutique transfers")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: { router.presentFullScreen(BMRoute.cycleCountSignoff) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Cycle Count Sign-off")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("\(viewModel.pendingCycleCountsCount) Audit ready for review")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: {
                                    // VM route. For now, pass a dummy UUID until StoreViewModel includes the actual boutique ID.
                                    router.push(BMRoute.planogramGallery(boutiqueId: UUID()))
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Visual Merchandising")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("View active store planograms")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 24)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("INVENTORY CONTROLS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)

                            VStack(spacing: 12) {
                                Button(action: { router.push(BMRoute.stockReconciliation) }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Stock Reconciliation")
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("Scan barcodes or QR codes to resolve quantity mismatches")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("UPCOMING EVENTS")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                Spacer()
                                Button(action: { router.presentFullScreen(BMRoute.createEvent) }) {
                                    Text("+ New Event")
                                        .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.events) { event in
                                    let isInteractive = event.type.uppercased() == "VIP PREVIEW" || event.type.uppercased() == "TRUNK SHOW" || event.type.uppercased() == "PRODUCT LAUNCH"
                                    Button(action: {
                                        if event.type.uppercased() == "VIP PREVIEW" {
                                            router.push(BMRoute.vipPreviewDetail(event))
                                        } else if event.type.uppercased() == "TRUNK SHOW" {
                                            router.push(BMRoute.trunkShowDetail(event))
                                        } else if event.type.uppercased() == "PRODUCT LAUNCH" {
                                            router.push(BMRoute.productLaunchDetail(event))
                                        }
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(event.type.uppercased())
                                                    .font(AppFonts.sansSerif(size: 8, weight: .bold))
                                                    .foregroundStyle(AppColors.background)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(AppColors.gold)
                                                    .clipShape(Capsule())
                                                Text(event.title)
                                                    .font(AppFonts.serif(size: 17, weight: .medium))
                                                    .foregroundStyle(.white)
                                                Text(event.date)
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text("\(event.rsvpCount)")
                                                    .font(AppFonts.serif(size: 20, weight: .bold))
                                                    .foregroundStyle(.white)
                                                Text("RSVPs")
                                                    .font(AppFonts.sansSerif(size: 10))
                                                    .foregroundStyle(AppColors.tertiary)
                                            }
                                            
                                            if isInteractive {
                                                Image(systemName: "chevron.right")
                                                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                                    .foregroundStyle(AppColors.gold)
                                                    .padding(.leading, 8)
                                            }
                                        }
                                        .padding(20)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isInteractive ? AppColors.gold.opacity(0.3) : Color.clear, lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!isInteractive)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .onAppear {
            viewModel.loadLocalEvents()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
