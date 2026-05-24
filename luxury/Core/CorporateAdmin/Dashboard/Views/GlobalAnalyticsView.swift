//
//  GlobalAnalyticsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI
import Charts

struct GlobalAnalyticsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = GlobalAnalyticsViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Global Overview")
                        .font(AppFonts.serif(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { coordinator.logout() }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.gold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(AppColors.background)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(viewModel.kpis) { kpi in
                                GlobalMetricCard(kpi: kpi)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("REVENUE TREND (CR)")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            Chart {
                                ForEach(viewModel.revenueChartData) { data in
                                    BarMark(
                                        x: .value("Month", data.month),
                                        y: .value("Amount", data.amount)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppColors.gold, AppColors.gold.opacity(0.5)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .cornerRadius(6)
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisValueLabel()
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ACTIVE BOUTIQUES")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.boutiquePerformance) { boutique in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(boutique.name)
                                                .font(AppFonts.serif(size: 17, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("\(boutique.city) · \(boutique.managerName)")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    .padding(18)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                }
                            }
                        }
                        .padding(.bottom, 60)
                    }
                    .padding(.top, 20)
                }
                .refreshable {
                    viewModel.fetchData()
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct GlobalMetricCard: View {
    let kpi: GlobalKPI
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: kpi.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.gold)
                Spacer()
                if kpi.trend != 0 {
                    HStack(spacing: 2) {
                        Image(systemName: kpi.trend > 0 ? "arrow.up.right" : "arrow.down.right")
                        Text("\(String(format: "%.1f", abs(kpi.trend)))%")
                    }
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(kpi.trend > 0 ? AppColors.success : AppColors.error)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(kpi.value)
                    .font(AppFonts.serif(size: 22, weight: .bold))
                    .foregroundStyle(.white)
                Text(kpi.label.uppercased())
                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
    }
}
