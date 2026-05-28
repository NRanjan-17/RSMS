//
//  ClientInsightsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ClientInsightsView: View {
    @State private var viewModel = ClientInsightsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Client Insights")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(spacing: 12) {
                            MetricCard(title: "Total VIPs", value: "\(viewModel.totalVIPs)", subtitle: "Active Profiles", icon: "person.2.fill")
                            MetricCard(title: "Avg LTV", value: viewModel.avgLTV, subtitle: "Lifetime Value", icon: "chart.line.uptrend.xyaxis")
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TIER BREAKDOWN")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(viewModel.tierBreakdown, id: \.id) { metric in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(metric.tier)
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text("\(metric.count) Clients")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Text(metric.revenue)
                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
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
