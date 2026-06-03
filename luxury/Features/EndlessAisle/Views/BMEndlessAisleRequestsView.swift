//
//  BMEndlessAisleRequestsView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 26/05/26.
//

import SwiftUI

public struct BMEndlessAisleRequestsView: View {
    @State private var viewModel = EndlessAisleViewModel.shared
    @State private var sourceOptions: [UUID: [EndlessAisle.BoutiqueStock]] = [:]
    @State private var selectedSources: [UUID: EndlessAisle.BoutiqueStock] = [:]
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        requestSection(
                            title: "OUTGOING ESCALATIONS",
                            emptyText: "No local Endless Aisle escalations need review.",
                            requests: viewModel.outgoingManagerRequests
                        ) { request in
                            outgoingCard(for: request)
                        }
                        
                        requestSection(
                            title: "INCOMING BOUTIQUE REQUESTS",
                            emptyText: "No other boutiques are requesting assistance.",
                            requests: viewModel.incomingManagerRequests
                        ) { request in
                            incomingCard(for: request)
                        }
                        
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
            viewModel.loadRequests()
        }
        .task(id: viewModel.outgoingManagerRequests) {
            await loadSourceOptions()
        }
    }
    
    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
            
            Text("Endless Aisle Approvals")
                .font(AppFonts.serif(size: 24, weight: .semibold))
                .foregroundStyle(AppColors.text)
            
            Spacer()
            
            Button(action: { viewModel.loadRequests() }) {
                Image(systemName: "arrow.clockwise")
                    .font(AppFonts.sansSerif(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
    
    @ViewBuilder
    private func requestSection<Content: View>(title: String, emptyText: String, requests: [EndlessAisle.SourcingRequest], @ViewBuilder content: @escaping (EndlessAisle.SourcingRequest) -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                .foregroundStyle(AppColors.secondary)
                .kerning(1.5)
                .padding(.horizontal, 24)
            
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
    
    private func outgoingCard(for request: EndlessAisle.SourcingRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            requestHeader(request, badge: "Needs Review", status: .pending)
            
            Text("Requested by local inventory control for \(request.destinationStore).")
                .font(AppFonts.sansSerif(size: 12))
                .foregroundStyle(AppColors.secondary)
            
            let options = sourceOptions[request.id] ?? []
            if options.isEmpty {
                Text("No boutiques currently have an available serial-numbered unit.")
                    .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.error)
            } else {
                Menu {
                    ForEach(options) { source in
                        Button("\(source.name), \(source.city) · \(source.quantity)") {
                            selectedSources[request.id] = source
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedSources[request.id].map { "\($0.name), \($0.city)" } ?? "Select source boutique")
                            .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(AppFonts.sansSerif(size: 12, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                    }
                    .padding(12)
                    .background(AppColors.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Button(action: {
                    guard let source = selectedSources[request.id] ?? options.first else { return }
                    viewModel.approveRequesterManager(request: request, sourceBoutique: source)
                }) {
                    actionLabel("Send Request", color: AppColors.gold)
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
    
    private func incomingCard(for request: EndlessAisle.SourcingRequest) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            requestHeader(request, badge: "Action Needed", status: .warning)
            
            Text("\(request.destinationStore) is requesting this item from your boutique.")
                .font(AppFonts.sansSerif(size: 12))
                .foregroundStyle(AppColors.secondary)
            
            Button(action: { viewModel.approveSourceManager(requestId: request.id) }) {
                actionLabel("Reserve Unit for Dispatch", color: AppColors.gold)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isSaving)
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
    }
    
    private func requestHeader(_ request: EndlessAisle.SourcingRequest, badge: LocalizedStringKey, status: BadgeStatus) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(request.item.name)
                    .font(AppFonts.serif(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.text)
                Text("SKU \(request.item.sku)")
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
    
    private func loadSourceOptions() async {
        for request in viewModel.outgoingManagerRequests {
            sourceOptions[request.id] = await viewModel.availableSourceBoutiques(for: request)
        }
    }
}

#Preview {
    BMEndlessAisleRequestsView()
}
