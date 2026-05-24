//
//  BoutiqueManagerSettingsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 25/05/26.
//

import SwiftUI

struct BoutiqueManagerSettingsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Settings")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREFERENCES")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Global Currency")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Picker("Currency", selection: $currencyManager.currentCurrency) {
                                        ForEach(AppCurrency.allCases) { currency in
                                            Text(currency.rawValue).tag(currency)
                                        }
                                    }
                                    .tint(AppColors.gold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        
                        CustomButton(title: "Logout", action: { coordinator.logout() })
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                }
            }
        }
    }
}
