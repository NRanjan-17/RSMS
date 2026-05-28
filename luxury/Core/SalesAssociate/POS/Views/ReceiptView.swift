//
//  ReceiptView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ReceiptView: View {
    @Environment(Router.self) private var router
    @Environment(SalesAssociateAppState.self) private var saAppState
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(AppColors.success.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(AppFonts.sansSerif(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.success)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Payment Successful")
                            .font(AppFonts.serif(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("Transaction ID: \(POSViewModel.shared.lastTransactionId ?? "#TX-PENDING")")
                            .font(AppFonts.sansSerif(size: 13))
                            .foregroundStyle(AppColors.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        Text(POSViewModel.shared.formatCurrency(POSViewModel.shared.lastTotalPaid ?? 0))
                            .font(AppFonts.serif(size: 40, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                        
                        Text("Paid securely via Razorpay")
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.tertiary)
                            
                        if let boutique = POSViewModel.shared.lastBoutique {
                            VStack(spacing: 4) {
                                Text(boutique.name)
                                    .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("\(boutique.address), \(boutique.city) - \(boutique.pinCode)")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.tertiary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                    
                    if !POSViewModel.shared.lastPurchasedItems.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(POSViewModel.shared.lastPurchasedItems, id: \.product.id) { item in
                                    HStack(alignment: .top) {
                                        Text("\(item.qty)x")
                                            .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                            .foregroundStyle(AppColors.secondary)
                                            
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.product.name)
                                                .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                                .foregroundStyle(.white)
                                            Text("S/N: \(item.product.barCode)")
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(POSViewModel.shared.formatCurrency(Int(item.product.amount) * item.qty))
                                            .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                            .foregroundStyle(.white)
                                    }
                                    
                                    Divider()
                                        .background(AppColors.border)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .frame(maxHeight: 150)
                        .padding(.bottom, 16)
                    }
                    
                    VStack(spacing: 12) {
                        CustomButton(title: "Email Receipt", icon: AnyView(Image(systemName: "envelope")), action: {})
                        CustomOutlineButton(title: "Print Receipt", icon: AnyView(Image(systemName: "printer")), action: {
                            printReceipt()
                        })
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await MainActor.run {
                            saAppState.selectedTab = .clients
                        }
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        await MainActor.run {
                            router.popToRoot()
                        }
                    }
                }) {
                    Text("Return to Dashboard")
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
    
    @MainActor
    private func printReceipt() {
        let receiptContent = VStack(spacing: 24) {
            Text("Payment Successful")
                .font(AppFonts.serif(size: 32, weight: .semibold))
                .foregroundStyle(Color.black)
            
            Text("Transaction ID: \(POSViewModel.shared.lastTransactionId ?? "#TX-PENDING")")
                .font(AppFonts.sansSerif(size: 13))
                .foregroundStyle(Color.gray)
            
            VStack(spacing: 12) {
                Text(POSViewModel.shared.formatCurrency(POSViewModel.shared.lastTotalPaid ?? 0))
                    .font(AppFonts.serif(size: 40, weight: .bold))
                    .foregroundStyle(Color.black)
                
                Text("Paid securely via Razorpay")
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(Color.gray)
                    
                if let boutique = POSViewModel.shared.lastBoutique {
                    VStack(spacing: 4) {
                        Text(boutique.name)
                            .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                            .foregroundStyle(Color.black)
                        Text("\(boutique.address), \(boutique.city) - \(boutique.pinCode)")
                            .font(AppFonts.sansSerif(size: 11))
                            .foregroundStyle(Color.gray)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.vertical, 16)
            
            if !POSViewModel.shared.lastPurchasedItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(POSViewModel.shared.lastPurchasedItems, id: \.product.id) { item in
                        HStack(alignment: .top) {
                            Text("\(item.qty)x")
                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                .foregroundStyle(Color.gray)
                                
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.product.name)
                                    .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                    .foregroundStyle(Color.black)
                                Text("S/N: \(item.product.barCode)")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(Color.gray)
                            }
                            
                            Spacer()
                            
                            Text(POSViewModel.shared.formatCurrency(Int(item.product.amount) * item.qty))
                                .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                .foregroundStyle(Color.black)
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }
            }
        }
        .padding(40)
        .background(Color.white)
        .frame(width: 400)
        
        let renderer = ImageRenderer(content: receiptContent)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            let printInfo = UIPrintInfo(dictionary: nil)
            printInfo.jobName = "Receipt"
            printInfo.outputType = .general
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            printController.printingItem = uiImage
            printController.present(animated: true, completionHandler: nil)
        }
    }
}
