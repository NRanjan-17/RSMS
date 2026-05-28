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
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 12) {
                        CustomButton(title: "Email Receipt", icon: AnyView(Image(systemName: "envelope")), action: {})
                        CustomOutlineButton(title: "Print Receipt", icon: AnyView(Image(systemName: "printer")), action: {})
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button(action: {
                    router.popToRoot()
                    saAppState.selectedTab = .clients
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
}
