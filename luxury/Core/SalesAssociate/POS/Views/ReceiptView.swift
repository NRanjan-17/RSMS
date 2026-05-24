//
//  ReceiptView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ReceiptView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
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
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AppColors.success)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Payment Successful")
                            .font(AppFonts.serif(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Text("Transaction ID: #TX-90428-RB")
                            .font(AppFonts.sansSerif(size: 13))
                            .foregroundStyle(AppColors.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        Text("\(CurrencyManager.shared.symbol)16,06,179")
                            .font(AppFonts.serif(size: 40, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                        
                        Text("Paid via Credit Card ending in 4242")
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
                    Task {
                        let session = await AuthService().getCurrentSession()
                        await coordinator.routingService.updateRoute(for: session)
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
}
