//
//  CycleCountDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct CycleCountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuditSignoffViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Audit Sign-off")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(spacing: 12) {
                            MetricCard(title: "Variance", value: viewModel.netVariance, subtitle: "Net Discrepancy", icon: "arrow.up.arrow.down")
                            MetricCard(title: "Accuracy", value: viewModel.accuracy, subtitle: "Store Performance", icon: "percent")
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DISCREPANCY REPORT")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(viewModel.variances) { item in
                                    CycleCountVarianceRow(item: item)
                                }
                            }
                        }
                        
                        CustomButton(title: "Sign-off Audit", action: { dismiss() })
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct CycleCountVarianceRow: View {
    let item: RSMSVarianceItem
    
    private var diff: Int {
        item.actual - item.expected
    }
    
    private var formattedDiff: String {
        "\(diff > 0 ? "+" : "")\(diff)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.name)
                    .font(AppFonts.serif(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text(formattedDiff)
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(diff == 0 ? AppColors.success : AppColors.error)
            }
            
            HStack {
                Text("Exp: \(item.expected)")
                Text("•")
                Text("Act: \(item.actual)")
                
                Spacer()
                
                Text(item.reason)
                    .font(AppFonts.sansSerif(size: 11).italic())
                    .foregroundStyle(AppColors.gold70)
            }
            .font(AppFonts.sansSerif(size: 12))
            .foregroundStyle(AppColors.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(AppColors.surface)
    }
}
