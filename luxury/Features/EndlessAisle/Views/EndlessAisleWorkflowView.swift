//
//  EndlessAisleWorkflowView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import SwiftUI

public struct EndlessAisleWorkflowView: View {
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
                    
                    Text("Endless Aisle Lookup")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(AppColors.text)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("STOCK ITEM SOURCE LIST")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            Text("Select an item to verify local and regional boutique availability.")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.mockItems) { item in
                                Button(action: { viewModel.checkStock(item: item) }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(AppColors.surface2)
                                                .frame(width: 48, height: 48)
                                            Image(systemName: "circle.grid.cross")
                                                .font(AppFonts.sansSerif(size: 18))
                                                .foregroundStyle(AppColors.gold)
                                                .opacity(0.3)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(item.name)
                                                .font(AppFonts.serif(size: 15, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            Text("SKU: \(item.sku)  ·  Delhi: \(item.stockDelhi)  ·  Paris: \(item.stockParis)")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if viewModel.selectedItem?.id == item.id {
                                            Circle()
                                                .fill(AppColors.gold)
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                    .padding(14)
                                    .background(viewModel.selectedItem?.id == item.id ? AppColors.gold08 : AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(viewModel.selectedItem?.id == item.id ? AppColors.gold : AppColors.gold15, lineWidth: 0.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        if let selected = viewModel.selectedItem {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("AVAILABILITY ASSESSMENT")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    if viewModel.isCheckingStock {
                                        HStack {
                                            Spacer()
                                            ProgressView("Assessing stock routes...")
                                                .tint(AppColors.gold)
                                                .foregroundStyle(AppColors.secondary)
                                            Spacer()
                                        }
                                    } else if let result = viewModel.currentCheckResult {
                                        switch result {
                                        case .localInStock:
                                            HStack(spacing: 12) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(AppColors.success)
                                                    .font(AppFonts.sansSerif(size: 20))
                                                Text("This item is in stock at DLF Emporio, Delhi. Sourcing not required.")
                                                    .font(AppFonts.sansSerif(size: 13))
                                                    .foregroundStyle(AppColors.success)
                                            }
                                            
                                        case .noStockAnywhere:
                                            HStack(spacing: 12) {
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .foregroundStyle(AppColors.error)
                                                    .font(AppFonts.sansSerif(size: 20))
                                                Text("Item out of stock at all regional locations.")
                                                    .font(AppFonts.sansSerif(size: 13))
                                                    .foregroundStyle(AppColors.error)
                                            }
                                            
                                        case .outOfStockLocally(let alternate):
                                            VStack(alignment: .leading, spacing: 14) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .foregroundStyle(AppColors.warning)
                                                        .font(AppFonts.sansSerif(size: 20))
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text("Out of Stock Locally")
                                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                                            .foregroundStyle(.white)
                                                        Text("Available for transfer from \(alternate).")
                                                            .font(AppFonts.sansSerif(size: 12))
                                                            .foregroundStyle(AppColors.secondary)
                                                    }
                                                }
                                                
                                                CustomButton(title: "Request Transfer from Paris Boutique") {
                                                    viewModel.createRequest(item: selected)
                                                    viewModel.selectedItem = nil
                                                    viewModel.currentCheckResult = nil
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(18)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        if !viewModel.activeRequests.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("ACTIVE SOURCING PIPELINES")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 16) {
                                    ForEach(viewModel.activeRequests) { request in
                                        VStack(alignment: .leading, spacing: 14) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(request.item.name)
                                                        .font(AppFonts.serif(size: 16, weight: .medium))
                                                        .foregroundStyle(AppColors.text)
                                                    Text("Source: \(request.sourceStore)  ➔  Delhi")
                                                        .font(AppFonts.sansSerif(size: 12))
                                                        .foregroundStyle(AppColors.secondary)
                                                }
                                                Spacer()
                                                StatusBadge(
                                                    text: LocalizedStringKey(request.status.rawValue),
                                                    status: badgeStatusFor(request.status)
                                                )
                                            }
                                            
                                            HStack(spacing: 4) {
                                                stepIndicator(label: "Requested", active: true, completed: request.status != .pendingBMAproval)
                                                stepLine(completed: request.status != .pendingBMAproval)
                                                stepIndicator(label: "BM Delhi", active: request.status != .pendingBMAproval, completed: request.status != .pendingBMAproval && request.status != .pendingBMBApproval)
                                                stepLine(completed: request.status != .pendingBMAproval && request.status != .pendingBMBApproval)
                                                stepIndicator(label: "BM Paris", active: request.status == .pendingICBDispatch || request.status == .dispatched, completed: request.status == .dispatched)
                                                stepLine(completed: request.status == .dispatched)
                                                stepIndicator(label: "Dispatched", active: request.status == .dispatched, completed: false)
                                            }
                                            .padding(.vertical, 4)
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text("LATEST EVENT:")
                                                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                    .foregroundStyle(AppColors.secondary)
                                                Text(request.history.last ?? "")
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.text)
                                            }
                                            .padding(10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppColors.surface2)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("ROLE SIMULATOR SHORTCUTS:")
                                                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                    .foregroundStyle(AppColors.gold)
                                                    .kerning(1)
                                                
                                                HStack(spacing: 8) {
                                                    if request.status == .pendingBMAproval {
                                                        simButton(title: "Approve as BM Delhi") {
                                                            viewModel.approveBMA(requestId: request.id)
                                                        }
                                                    } else if request.status == .pendingBMBApproval {
                                                        simButton(title: "Authorize as BM Paris") {
                                                            viewModel.approveBMB(requestId: request.id)
                                                        }
                                                    } else if request.status == .pendingICBDispatch {
                                                        simButton(title: "Dispatch as IC Paris") {
                                                            viewModel.dispatchICB(requestId: request.id)
                                                        }
                                                    } else {
                                                        Text("✓ Pipeline Sourced Successfully")
                                                            .font(AppFonts.sansSerif(size: 11, weight: .semibold))
                                                            .foregroundStyle(AppColors.success)
                                                    }
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                        .padding(18)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.gold15, lineWidth: 0.5))
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
    
    private func badgeStatusFor(_ status: EndlessAisle.RequestState) -> BadgeStatus {
        switch status {
        case .checking: return .neutral
        case .localInStock: return .success
        case .noStockAnywhere: return .error
        case .pendingBMAproval: return .pending
        case .pendingBMBApproval: return .pending
        case .pendingICBDispatch: return .warning
        case .dispatched: return .success
        }
    }
    
    @ViewBuilder
    private func stepIndicator(label: String, active: Bool, completed: Bool) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(completed ? AppColors.success : (active ? AppColors.gold : AppColors.tertiary))
                .frame(width: 8, height: 8)
            Text(label)
                .font(AppFonts.sansSerif(size: 8, weight: .bold))
                .foregroundStyle(active ? AppColors.text : AppColors.secondary)
        }
    }
    
    @ViewBuilder
    private func stepLine(completed: Bool) -> some View {
        Rectangle()
            .fill(completed ? AppColors.success : AppColors.tertiary)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .offset(y: -6)
    }
    
    @ViewBuilder
    private func simButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                .foregroundStyle(AppColors.background)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.gold)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EndlessAisleWorkflowView()
}
