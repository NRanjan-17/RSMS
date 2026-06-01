//
//  SFSVerificationView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 22/05/26.
//

import SwiftUI

struct SFSVerificationView: View {
    let order: PurchasedItemEntity
    @Environment(Router.self) private var router
    @Environment(FulfillmentViewModel.self) private var viewModel
    
    @State private var inputSku: String = ""
    @State private var isVerified: Bool = false
    @State private var scanError: String? = nil
    
    @State private var check1: Bool = false
    @State private var check2: Bool = false
    @State private var check3: Bool = false
    
    @State private var isUpdating: Bool = false
    @State private var laserOffset: CGFloat = -110
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var userRole: UserRole? = nil
    
    private var allChecked: Bool {
        check1 && check2 && check3
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Verify & Match Item")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ORDER DETAILS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Order ID")
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(order.id.uuidString.prefix(8).uppercased())
                                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                
                                Divider().background(AppColors.border)
                                
                                HStack {
                                    Text("Watch Name")
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(order.productName ?? "Premium Timepiece")
                                        .font(AppFonts.serif(size: 15, weight: .medium))
                                        .foregroundStyle(AppColors.text)
                                        .multilineTextAlignment(.trailing)
                                }
                                
                                Divider().background(AppColors.border)
                                
                                HStack {
                                    Text("Expected SKU")
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(order.productSku ?? "N/A")
                                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                
                                Divider().background(AppColors.border)
                                
                                HStack {
                                    Text("Store Location")
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(order.storeLocation ?? "Vault - Aisle A, Shelf 1")
                                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        
                        Button(action: {
                            isUpdating = true
                            Task {
                                let success = await viewModel.flagItemAsMissing(orderId: order.id)
                                if success {
                                    router.pop()
                                } else {
                                    await MainActor.run {
                                        alertMessage = viewModel.errorMessage ?? "Failed to flag item as missing."
                                        showAlert = true
                                    }
                                }
                                isUpdating = false
                            }
                        }) {
                            Text("Flag Item as Missing")
                                .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.error.opacity(0.8))
                                )
                        }
                        .disabled(isUpdating)
                        .padding(.horizontal, 24)
                        
                        if userRole == .inventoryController {
                            Button(action: {
                                isUpdating = true
                                Task {
                                    let success = await viewModel.updateStatusToSecured(orderId: order.id)
                                    if success {
                                        router.pop()
                                    } else {
                                        await MainActor.run {
                                            alertMessage = viewModel.errorMessage ?? "An unknown error occurred."
                                            showAlert = true
                                        }
                                    }
                                    isUpdating = false
                                }
                            }) {
                                HStack {
                                    if isUpdating {
                                        ProgressView()
                                            .tint(AppColors.background)
                                            .controlSize(.small)
                                    } else {
                                        Text("Mark as Secured")
                                    }
                                }
                                .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(AppColors.gold)
                                )
                                .opacity(isUpdating ? 0.5 : 1.0)
                            }
                            .disabled(isUpdating)
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Fulfillment Alert"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            if let profile = try? await ProfileService().fetchCurrentProfile() {
                userRole = profile.0
            }
        }
    }
}
