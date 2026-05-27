//
//  ActiveAuditView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ActiveAuditView: View {
    let audit: RSMSCycleCount
    @Environment(Router.self) private var router
    @State private var viewModel: ActiveAuditViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(audit: RSMSCycleCount) {
        self.audit = audit
        self._viewModel = State(initialValue: ActiveAuditViewModel(audit: audit))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        router.dismissModal()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text(audit.title)
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Audit Progress")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                        Spacer()
                        Text("\(viewModel.totalScanned)/\(viewModel.totalExpected) items")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.surface).frame(height: 4)
                        if viewModel.totalExpected > 0 {
                            Capsule().fill(AppColors.gold).frame(width: min(300, 300 * viewModel.progress), height: 4)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("BARCODE SCAN SIMULATOR")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.expectedItems) { item in
                                        Button(action: {
                                            let _ = viewModel.scanItem(barcode: item.barcode)
                                        }) {
                                            HStack {
                                                Image(systemName: "barcode.viewfinder")
                                                    .font(.system(size: 14))
                                                Text("Scan \(item.name)")
                                                    .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(AppColors.surface2)
                                            .foregroundStyle(AppColors.gold)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(AppColors.gold50, lineWidth: 0.5))
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        Text("SCANNED ITEMS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.tertiary)
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                        
                        if viewModel.scannedItems.isEmpty {
                            Text("No items scanned yet")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(viewModel.scannedItems) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(item.ok ? .white : AppColors.error)
                                            Text(item.ok ? "MATCHED" : "OVER EXPECTED QUANTITY")
                                                .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                        }
                                        Spacer()
                                        Image(systemName: item.ok ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                            .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surface)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    CustomOutlineButton(title: "Recount", icon: AnyView(Image(systemName: "arrow.clockwise")), action: {
                        Task {
                            await viewModel.loadExpectedItems()
                            viewModel.saveSessionState()
                        }
                    })
                    CustomButton(title: "Submit", icon: AnyView(Image(systemName: "checkmark.shield")), action: {
                        Task {
                            let result = await viewModel.submitCount()
                            switch result {
                            case .success:
                                router.dismissModal()
                                router.push(ICRoute.varianceReport(audit))
                            case .failure:
                                break
                            }
                        }
                    })
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.startSession()
        }
    }
}
