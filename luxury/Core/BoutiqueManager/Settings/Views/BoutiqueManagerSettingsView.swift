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
    @State private var targetText: String = ""
    @State private var showTargetSaved = false
    
    private var currentTarget: Double {
        UserDefaults.standard.double(forKey: "bm_daily_sales_target")
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Settings")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        
                        // MARK: – Daily Sales Target
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("DAILY SALES TARGET")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                Text("This target applies every day until you change it")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.tertiary)
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 16) {
                                if currentTarget > 0 {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Image(systemName: "target")
                                                .font(.system(size: 14))
                                                .foregroundStyle(AppColors.gold)
                                            Text("Active Target")
                                                .font(AppFonts.sansSerif(size: 13))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Text(formatCurrency(currentTarget))
                                            .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    HStack(spacing: 6) {
                                        Text(CurrencyManager.shared.symbol)
                                            .font(AppFonts.sansSerif(size: 16, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                        
                                        TextField("e.g. 1500000", text: $targetText)
                                            .font(AppFonts.sansSerif(size: 15))
                                            .foregroundStyle(AppColors.text)
                                            .keyboardType(.numberPad)
                                    }
                                    .padding(12)
                                    .background(AppColors.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                                    
                                    Button(action: {
                                        if let value = Double(targetText.replacingOccurrences(of: ",", with: "")), value > 0 {
                                            UserDefaults.standard.set(value, forKey: "bm_daily_sales_target")
                                            targetText = ""
                                            withAnimation {
                                                showTargetSaved = true
                                            }
                                            Task {
                                                try? await Task.sleep(nanoseconds: 2_000_000_000)
                                                withAnimation {
                                                    showTargetSaved = false
                                                }
                                            }
                                        }
                                    }) {
                                        Text("Set")
                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.background)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 13)
                                            .background(AppColors.gold)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                                
                                if showTargetSaved {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Target updated successfully")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(.green)
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(16)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        
                        // MARK: – Preferences
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
    
    private func formatCurrency(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = CurrencyManager.shared.symbol
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "en_IN")
        return f.string(from: NSNumber(value: value)) ?? "\(CurrencyManager.shared.symbol)0"
    }
}
