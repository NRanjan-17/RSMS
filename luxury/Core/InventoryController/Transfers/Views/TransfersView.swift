//
//  TransfersView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct TransfersView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = TransfersViewModel()
    @State private var selectedFilter = 0
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Transfers")
                
                VStack(spacing: 20) {
                    CustomButton(title: "New Transfer Request", icon: AnyView(Image(systemName: "plus.circle")), action: {
                        router.presentFullScreen(ICRoute.newTransfer)
                    })
                }
                .padding(24)
                
                Picker("Filter", selection: $selectedFilter) {
                    Text("Pending").tag(0)
                    Text("In Transit").tag(1)
                    Text("Completed").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.pendingTransfers) { transfer in
                            Button(action: { router.presentFullScreen(ICRoute.transferDetail(transfer)) }) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text(transfer.reference)
                                            .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                        Spacer()
                                        StatusBadge(text: transfer.status, status: transfer.badgeStatus)
                                    }
                                    
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(transfer.source)
                                                .font(AppFonts.serif(size: 16))
                                                .foregroundStyle(AppColors.text)
                                            Text("SOURCE")
                                                .font(AppFonts.sansSerif(size: 8))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(transfer.destination)
                                                .font(AppFonts.serif(size: 16))
                                                .foregroundStyle(AppColors.text)
                                            Text("DESTINATION")
                                                .font(AppFonts.sansSerif(size: 8))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(transfer.itemCount) items")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                }
                                .padding(16)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
