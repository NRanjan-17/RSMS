//
//  SalesAnalyticsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct SalesAnalyticsView: View {
    @State private var viewModel = SalesAnalyticsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    
                    Text("Sales Analytics")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                MetricCard(title: "Today's Sales", value: viewModel.todaySales, subtitle: "Target: \(viewModel.todayTarget)", icon: "indianrupeesign")
                                MetricCard(title: "WTD Sales", value: viewModel.wtdSales, subtitle: "Week to Date", icon: "calendar")
                            }
                            HStack(spacing: 12) {
                                MetricCard(title: "MTD Sales", value: viewModel.mtdSales, subtitle: "Month to Date", icon: "calendar.badge.clock")
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("REVENUE BY CATEGORY")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(viewModel.categories, id: \.id) { category in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(category.name)
                                                .font(AppFonts.serif(size: 17, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("\(Int(category.percentage * 100))% of Total Revenue")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Text(category.revenue)
                                            .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 18)
                                    .background(AppColors.surface)
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
