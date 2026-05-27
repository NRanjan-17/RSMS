//
//  SFSVerificationView.swift
//  luxury
//
//  Created by Antigravity on 22/05/26.
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
                            .font(.system(size: 20, weight: .semibold))
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
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SCANNER MODULE")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            ZStack {
                                AppColors.surface
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isVerified ? AppColors.success.opacity(0.4) : AppColors.gold15, lineWidth: 1)
                                    )
                                
                                if isVerified {
                                    VStack(spacing: 16) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 64))
                                            .foregroundStyle(AppColors.success)
                                        
                                        Text("VERIFICATION MATCH SUCCESSFUL")
                                            .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.success)
                                            .kerning(1)
                                        
                                        Text("SKU matches order target: \(order.productSku ?? "")")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    .padding(40)
                                } else {
                                    VStack(spacing: 20) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.6))
                                                .frame(width: 240, height: 160)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(AppColors.gold50, lineWidth: 1.5)
                                                )
                                            
                                            Rectangle()
                                                .fill(Color.red)
                                                .frame(width: 220, height: 2)
                                                .shadow(color: .red, radius: 4)
                                                .offset(y: laserOffset)
                                                .onAppear {
                                                    withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                                                        laserOffset = 70
                                                    }
                                                }
                                            
                                            Image(systemName: "barcode.viewfinder")
                                                .font(.system(size: 40))
                                                .foregroundStyle(AppColors.gold.opacity(0.3))
                                        }
                                        .frame(height: 180)
                                        
                                        if let scanError = scanError {
                                            Text(scanError)
                                                .font(AppFonts.sansSerif(size: 13))
                                                .foregroundStyle(AppColors.error)
                                        }
                                        
                                        Button(action: {
                                            let result = viewModel.verifyScannedSku(orderSku: order.productSku, scannedCode: order.productSku ?? "")
                                            switch result {
                                            case .success:
                                                withAnimation {
                                                    isVerified = true
                                                    scanError = nil
                                                }
                                            case .failure(let error):
                                                withAnimation {
                                                    scanError = error.localizedDescription
                                                }
                                            }
                                        }) {
                                            Text("Simulate Barcode Scan")
                                                .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                                .foregroundStyle(AppColors.background)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 12)
                                                .background(AppColors.gold)
                                                .clipShape(Capsule())
                                        }
                                    }
                                    .padding(.vertical, 24)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        if !isVerified {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("TORN / UNREADABLE LABEL MANUAL ENTRY")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                HStack(spacing: 12) {
                                    TextField("Enter SKU or Product Code", text: $inputSku)
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.text)
                                        .padding()
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(AppColors.border, lineWidth: 1)
                                        )
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.characters)
                                    
                                    Button(action: {
                                        let result = viewModel.verifyScannedSku(orderSku: order.productSku, scannedCode: inputSku)
                                        switch result {
                                        case .success:
                                            withAnimation {
                                                isVerified = true
                                                scanError = nil
                                            }
                                        case .failure(let error):
                                            withAnimation {
                                                scanError = error.localizedDescription
                                            }
                                        }
                                    }) {
                                        Text("Verify")
                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.background)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 14)
                                            .background(AppColors.gold)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("VERIFICATION CHECKLIST")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    Toggle(isOn: $check1) {
                                        Text("Confirm timepiece matches requested model specifications")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                    .toggleStyle(LuxuryToggleStyle())
                                    
                                    Divider().background(AppColors.border)
                                    
                                    Toggle(isOn: $check2) {
                                        Text("Confirm physical watch shows zero defects or scratches")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                    .toggleStyle(LuxuryToggleStyle())
                                    
                                    Divider().background(AppColors.border)
                                    
                                    Toggle(isOn: $check3) {
                                        Text("Confirm certificates, warranty card, and luxury box are complete")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                    .toggleStyle(LuxuryToggleStyle())
                                }
                                .padding(20)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                                
                                if userRole == .inventoryController {
                                    Button(action: {
                                        guard userRole == .inventoryController else {
                                            alertMessage = "Unauthorized: Action is restricted to Inventory Controllers."
                                            showAlert = true
                                            return
                                        }
                                        isUpdating = true
                                        Task {
                                            let success = await viewModel.updateStatusToSecured(orderId: order.id)
                                            if success {
                                                router.pop()
                                            } else {
                                                await MainActor.run {
                                                    alertMessage = viewModel.errorMessage ?? "An unknown conflict occurred."
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
                                        .opacity(allChecked && !isUpdating ? 1.0 : 0.5)
                                    }
                                    .disabled(!allChecked || isUpdating)
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal, 24)
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
