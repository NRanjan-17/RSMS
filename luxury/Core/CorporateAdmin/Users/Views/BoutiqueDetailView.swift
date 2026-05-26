//
//  BoutiqueDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 20/05/26.
//

import SwiftUI

struct BoutiqueDetailView: View {
    @State private var currentBoutique: CorporateBoutique
    let originalBoutiqueId: UUID
    @Bindable var viewModel: UserManagementViewModel
    @Environment(Router.self) private var router
    @State private var showEditBoutique = false

    init(boutique: CorporateBoutique, viewModel: UserManagementViewModel) {
        _currentBoutique = State(initialValue: boutique)
        self.originalBoutiqueId = boutique.id
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {

                    Text("Boutique Details")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    
                    Button(action: { showEditBoutique = true }) {
                        Text("Edit")
                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                            .foregroundStyle(AppColors.gold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(currentBoutique.name)
                                .font(AppFonts.serif(size: 32, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                            Text("\(currentBoutique.city) · \(currentBoutique.status.rawValue.capitalized)")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(statusColor(currentBoutique.status))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("MANAGER DETAILS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                InfoDetailRow(label: "Manager Name", value: currentBoutique.managerName)
                                InfoDetailRow(label: "Manager Email", value: currentBoutique.managerEmail)
                                InfoDetailRow(label: "Manager Phone", value: currentBoutique.managerPhone)
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LOCATION DETAILS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                InfoDetailRow(label: "City", value: currentBoutique.city)
                                InfoDetailRow(label: "Address", value: currentBoutique.address)
                                InfoDetailRow(label: "Pin Code", value: currentBoutique.pinCode)
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        
                        if let error = viewModel.actionErrorMessage, viewModel.actionBoutiqueId == currentBoutique.id {
                            Text(error)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.error)
                                .padding(.horizontal, 24)
                        }
                        
                        if currentBoutique.status == .pending {
                            VStack(spacing: 16) {
                                Button(action: {
                                    viewModel.approveBoutique(currentBoutique) {
                                        router.pop()
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        if viewModel.actionBoutiqueId == currentBoutique.id {
                                            ProgressView().tint(.black)
                                        } else {
                                            Text("Approve Request")
                                                .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                                .foregroundStyle(.black)
                                        }
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                    .background(AppColors.gold)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .disabled(viewModel.actionBoutiqueId != nil)
                                
                                Button(action: {
                                    viewModel.rejectBoutique(currentBoutique) {
                                        router.pop()
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Reject Request")
                                            .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.error)
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppColors.error, lineWidth: 1)
                                    )
                                }
                                .disabled(viewModel.actionBoutiqueId != nil)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        } else if currentBoutique.status == .approved || currentBoutique.status == .paused {
                            VStack(spacing: 16) {
                                if currentBoutique.status == .approved {
                                    Button(action: {
                                        viewModel.disableBoutique(currentBoutique) {
                                            router.pop()
                                        }
                                    }) {
                                        HStack {
                                            Spacer()
                                            if viewModel.actionBoutiqueId == currentBoutique.id {
                                                ProgressView().tint(.white)
                                            } else {
                                                Text("Disable Boutique")
                                                    .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                                    .foregroundStyle(.white)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .background(AppColors.gold.opacity(0.8))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .disabled(viewModel.actionBoutiqueId != nil)
                                } else {
                                    Button(action: {
                                        viewModel.enableBoutique(currentBoutique) {
                                            router.pop()
                                        }
                                    }) {
                                        HStack {
                                            Spacer()
                                            if viewModel.actionBoutiqueId == currentBoutique.id {
                                                ProgressView().tint(.white)
                                            } else {
                                                Text("Enable Boutique")
                                                    .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                                    .foregroundStyle(.white)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 16)
                                        .background(Color.green)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .disabled(viewModel.actionBoutiqueId != nil)
                                }
                                
                                Button(action: {
                                    viewModel.removeBoutique(currentBoutique) {
                                        router.pop()
                                    }
                                }) {
                                    HStack {
                                        Spacer()
                                        Text("Remove Boutique")
                                            .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.error)
                                        Spacer()
                                    }
                                    .padding(.vertical, 16)
                                    .background(Color.clear)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppColors.error, lineWidth: 1)
                                    )
                                }
                                .disabled(viewModel.actionBoutiqueId != nil)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showEditBoutique, onDismiss: {
            Task {
                if let updated = try? await ProfileService().fetchBoutique(id: originalBoutiqueId) {
                    await MainActor.run {
                        self.currentBoutique = updated
                    }
                }
            }
        }) {
            EditBoutiqueView(viewModel: EditBoutiqueViewModel(boutique: currentBoutique))
        }
    }
    
    private func statusColor(_ status: EntityStatus) -> Color {
        switch status {
        case .pending:
            return AppColors.gold
        case .approved:
            return .green
        case .rejected:
            return AppColors.error
        case .paused:
            return .orange
        }
    }
}

private struct InfoDetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(AppColors.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                .foregroundStyle(AppColors.text)
                .multilineTextAlignment(.trailing)
        }
    }
}
