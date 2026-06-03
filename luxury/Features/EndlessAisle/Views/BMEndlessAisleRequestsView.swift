//
//  BMEndlessAisleRequestsView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import SwiftUI

public struct BMEndlessAisleRequestsView: View {
    @State private var viewModel = EndlessAisleViewModel.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    .accessibilityLabel("Back")
                    
                    Text("Endless Aisle Approvals")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(AppColors.text)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        let outgoing = viewModel.activeRequests.filter { $0.status == .pendingBMAproval }
                        VStack(alignment: .leading, spacing: 14) {
                            Text("OUTGOING REQUESTS (DELHI TO PARIS)")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .accessibilityAddTraits(.isHeader)
                            
                            if outgoing.isEmpty {
                                Text("No outgoing requests awaiting Delhi manager approval.")
                                    .font(AppFonts.sansSerif(size: 13))
                                    .foregroundStyle(AppColors.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(outgoing) { request in
                                        VStack(alignment: .leading, spacing: 14) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(request.item.name)
                                                        .font(AppFonts.serif(size: 16, weight: .medium))
                                                        .foregroundStyle(AppColors.text)
                                                    Text("Requested by Inventory Controller (Delhi)")
                                                        .font(AppFonts.sansSerif(size: 12))
                                                        .foregroundStyle(AppColors.secondary)
                                                }
                                                Spacer()
                                                StatusBadge(text: LocalizedStringKey("Pending"), status: .pending)
                                            }
                                            .accessibilityElement(children: .combine)
                                            
                                            HStack(spacing: 12) {
                                                Button(action: { viewModel.approveBMA(requestId: request.id) }) {
                                                    Text("Approve and Request from Paris")
                                                        .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                                        .foregroundStyle(AppColors.background)
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 40)
                                                        .background(AppColors.gold)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(16)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        let incoming = viewModel.activeRequests.filter { $0.status == .pendingBMBApproval }
                        VStack(alignment: .leading, spacing: 14) {
                            Text("INCOMING REQUESTS (PARIS TO DELHI)")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .accessibilityAddTraits(.isHeader)
                            
                            if incoming.isEmpty {
                                Text("No incoming requests awaiting Paris manager authorization.")
                                    .font(AppFonts.sansSerif(size: 13))
                                    .foregroundStyle(AppColors.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(incoming) { request in
                                        VStack(alignment: .leading, spacing: 14) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(request.item.name)
                                                        .font(AppFonts.serif(size: 16, weight: .medium))
                                                        .foregroundStyle(AppColors.text)
                                                    Text("Destination: DLF Emporio, Delhi")
                                                        .font(AppFonts.sansSerif(size: 12))
                                                        .foregroundStyle(AppColors.secondary)
                                                }
                                                Spacer()
                                                StatusBadge(text: LocalizedStringKey("Action Needed"), status: .warning)
                                            }
                                            .accessibilityElement(children: .combine)
                                            
                                            HStack(spacing: 12) {
                                                Button(action: { viewModel.approveBMB(requestId: request.id) }) {
                                                    Text("Authorize Stock Transfer")
                                                        .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                                        .foregroundStyle(AppColors.background)
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 40)
                                                        .background(AppColors.gold)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(16)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        let history = viewModel.activeRequests.filter { $0.status == .pendingICBDispatch || $0.status == .dispatched }
                        VStack(alignment: .leading, spacing: 14) {
                            Text("HISTORY & LOGS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .accessibilityAddTraits(.isHeader)
                            
                            if history.isEmpty {
                                Text("No recent transfer requests recorded.")
                                    .font(AppFonts.sansSerif(size: 13))
                                    .foregroundStyle(AppColors.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(history) { request in
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(request.item.name)
                                                    .font(AppFonts.serif(size: 15, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text("Status: \(request.status.rawValue.capitalized)")
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            Spacer()
                                            StatusBadge(
                                                text: LocalizedStringKey(request.status.rawValue),
                                                status: request.status == .dispatched ? .success : .neutral
                                            )
                                        }
                                        .padding(16)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                        .accessibilityElement(children: .combine)
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    BMEndlessAisleRequestsView()
}
