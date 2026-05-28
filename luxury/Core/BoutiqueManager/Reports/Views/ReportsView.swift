//
//  ReportsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ReportsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(Router.self) private var router
    @State private var viewModel = ReportsViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Analytical Reports")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AVAILABLE MODULES")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(viewModel.reportCategories) { report in
                                Button(action: {
                                    if let route = route(for: report.title) {
                                        router.push(route)
                                    }
                                }) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppColors.gold08)
                                                .frame(width: 44, height: 44)
                                            Image(systemName: report.icon)
                                                .font(AppFonts.sansSerif(size: 18))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(report.title)
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text(report.subtitle)
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.gold15, lineWidth: 0.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "lock.shield")
                                .font(AppFonts.sansSerif(size: 24))
                                .foregroundStyle(AppColors.tertiary)
                            Text("Data reflects the last synchronized state.\nSensitive PII is masked in aggregate views.")
                                .font(AppFonts.sansSerif(size: 11))
                                .foregroundStyle(AppColors.tertiary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func route(for title: String) -> BMRoute? {
        switch title {
        case "Sales Analytics":
            return .salesAnalytics
        case "Staff Performance":
            return .staffPerformanceReport
        case "Shrink & Inventory":
            return .shrinkReport
        case "Client Insights":
            return .clientInsights
        default:
            return nil
        }
    }
}
