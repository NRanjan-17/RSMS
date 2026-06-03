//
//  EndlessAisleWorkflowView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import SwiftUI

public struct EndlessAisleWorkflowView: View {
    @State private var viewModel = EndlessAisleViewModel.shared
    @State private var scannedCode = ""
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        catalogSection
                        availabilitySection
                        dispatchSection
                        receiveSection
                        activeSection
                        
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.error)
                                .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            viewModel.loadCatalogAvailability()
            viewModel.loadRequests()
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
            
            Text("Endless Aisle")
                .font(AppFonts.serif(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.text)
            
            Spacer()
            
            Button(action: {
                viewModel.loadCatalogAvailability()
                viewModel.loadRequests()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(AppFonts.sansSerif(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    private var catalogSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                sectionTitle("STOCK ITEM SOURCE LIST")
                Text("Select an item to verify local and regional boutique availability.")
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.secondary)
                    .padding(.horizontal, 24)
            }
            
            if viewModel.items.isEmpty {
                Text(viewModel.isLoading ? "Loading catalog availability..." : "No active catalog items found.")
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.secondary)
                    .padding(.horizontal, 24)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
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
                                    Text("SKU: \(item.sku) · Local available: \(item.localQuantity)")
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
            }
        }
    }
    
    @ViewBuilder
    private var availabilitySection: some View {
        if let selected = viewModel.selectedItem {
            VStack(alignment: .leading, spacing: 16) {
                sectionTitle("AVAILABILITY ASSESSMENT")
                
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isCheckingStock {
                        ProgressView("Assessing stock routes...")
                            .tint(AppColors.gold)
                            .foregroundStyle(AppColors.secondary)
                            .frame(maxWidth: .infinity)
                    } else if let result = viewModel.currentCheckResult {
                        switch result {
                        case .localInStock:
                            statusRow(icon: "checkmark.circle.fill", color: AppColors.success, title: "Local stock is available", subtitle: "Sourcing is not required for \(selected.name).")
                        case .noStockAnywhere:
                            statusRow(icon: "exclamationmark.triangle.fill", color: AppColors.error, title: "No source boutique found", subtitle: "No approved boutique currently has an available unit.")
                        case .outOfStockLocally(let alternatives):
                            VStack(alignment: .leading, spacing: 12) {
                                statusRow(icon: "shippingbox.fill", color: AppColors.warning, title: "Available outside this boutique", subtitle: "\(alternatives.count) boutique\(alternatives.count == 1 ? "" : "s") can source this item.")
                                ForEach(alternatives) { source in
                                    Text("\(source.name), \(source.city) · \(source.quantity) available")
                                        .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                        .foregroundStyle(AppColors.text)
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(AppColors.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
                .padding(18)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.gold15, lineWidth: 0.5))
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var dispatchSection: some View {
        requestSection(
            title: "AUTHORIZED DISPATCHES",
            emptyText: "No approved source requests are waiting for dispatch.",
            requests: viewModel.sourceDispatchRequests
        ) { request in
            VStack(alignment: .leading, spacing: 14) {
                requestHeader(request, badge: request.status == .dispatched ? "In Transit" : "Ready", status: request.status == .dispatched ? .pending : .warning)
                Text("Prepare serial \(request.serialNumber ?? "reserved unit") for \(request.destinationStore).")
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.secondary)
                
                if request.status == .pendingSourceDispatch {
                    Button(action: { viewModel.dispatchSourceRequest(request: request) }) {
                        actionLabel("Dispatch Item", color: AppColors.gold)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isSaving)
                }
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
        }
    }
    
    private var receiveSection: some View {
        requestSection(
            title: "ARRIVALS TO RECEIVE",
            emptyText: "No sourced items have arrived for this boutique.",
            requests: viewModel.destinationReceiveRequests
        ) { request in
            VStack(alignment: .leading, spacing: 14) {
                requestHeader(request, badge: "Arrived", status: .success)
                
                TextField("Scan serial number or SKU", text: $scannedCode)
                    .font(AppFonts.sansSerif(size: 14))
                    .foregroundStyle(AppColors.text)
                    .padding(12)
                    .background(AppColors.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .textInputAutocapitalization(.characters)
                
                Button(action: {
                    viewModel.receiveSourcedStock(request: request, scannedCode: scannedCode)
                    scannedCode = ""
                }) {
                    actionLabel("Receive Into Inventory", color: AppColors.success)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSaving || scannedCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
        }
    }
    
    private var activeSection: some View {
        requestSection(
            title: "ACTIVE SOURCING",
            emptyText: "No Endless Aisle sourcing pipelines are active.",
            requests: viewModel.activeRequests
        ) { request in
            VStack(alignment: .leading, spacing: 10) {
                requestHeader(request, badge: LocalizedStringKey(statusText(for: request.status)), status: badgeStatusFor(request.status))
                Text(request.history.last ?? "")
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.secondary)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
        }
    }
    
    @ViewBuilder
    private func requestSection<Content: View>(title: String, emptyText: String, requests: [EndlessAisle.SourcingRequest], @ViewBuilder content: @escaping (EndlessAisle.SourcingRequest) -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle(title)
            
            if requests.isEmpty {
                Text(emptyText)
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.secondary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
            } else {
                VStack(spacing: 12) {
                    ForEach(requests, content: content)
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppFonts.sansSerif(size: 10, weight: .bold))
            .foregroundStyle(AppColors.secondary)
            .kerning(1.5)
            .padding(.horizontal, 24)
    }
    
    private func statusRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(AppFonts.sansSerif(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.text)
                Text(subtitle)
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.secondary)
            }
            Spacer()
        }
    }
    
    private func requestHeader(_ request: EndlessAisle.SourcingRequest, badge: LocalizedStringKey, status: BadgeStatus) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(request.item.name)
                    .font(AppFonts.serif(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.text)
                Text("\(request.sourceStore) -> \(request.destinationStore)")
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.secondary)
            }
            Spacer()
            StatusBadge(text: badge, status: status)
        }
    }
    
    private func actionLabel(_ title: String, color: Color) -> some View {
        Text(title)
            .font(AppFonts.sansSerif(size: 13, weight: .semibold))
            .foregroundStyle(AppColors.background)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func badgeStatusFor(_ status: EndlessAisle.RequestState) -> BadgeStatus {
        switch status {
        case .checking:
            return .neutral
        case .localInStock:
            return .success
        case .noStockAnywhere:
            return .error
        case .pendingBoutiqueManagerApproval, .pendingSourceBoutiqueApproval:
            return .pending
        case .pendingSourceDispatch:
            return .warning
        case .dispatched:
            return .pending
        case .arrived, .received:
            return .success
        }
    }
    
    private func statusText(for status: EndlessAisle.RequestState) -> String {
        switch status {
        case .checking:
            return "Checking"
        case .localInStock:
            return "Local"
        case .noStockAnywhere:
            return "No Stock"
        case .pendingBoutiqueManagerApproval:
            return "Manager Review"
        case .pendingSourceBoutiqueApproval:
            return "Source Review"
        case .pendingSourceDispatch:
            return "Dispatch"
        case .dispatched:
            return "In Transit"
        case .arrived:
            return "Arrived"
        case .received:
            return "Received"
        }
    }
}

#Preview {
    EndlessAisleWorkflowView()
}
