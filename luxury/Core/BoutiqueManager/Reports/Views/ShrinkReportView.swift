//
//  ShrinkReportView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ShrinkReportView: View {
    @State private var viewModel = ShrinkReportViewModel()
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
                    Text("Shrink & Inventory")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        HStack(spacing: 12) {
                            MetricCard(title: "Shrink Value", value: viewModel.totalShrinkValue, subtitle: "MTD Write-offs", icon: "archivebox")
                            MetricCard(title: "Accuracy", value: viewModel.accuracy, subtitle: "Inventory Health", icon: "checkmark.shield")
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("RECENT DISCREPANCIES")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(viewModel.recentWriteOffs) { item in
                                    ShrinkWriteOffRow(item: item)
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

private struct ShrinkWriteOffRow: View {
    let item: RSMSVarianceItem
    
    private var diff: Int {
        item.actual - item.expected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.name)
                    .font(AppFonts.serif(size: 17, weight: .medium))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("\(diff)")
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.error)
            }
            
            HStack {
                Text("Expected: \(item.expected)")
                Text("•")
                Text("Actual: \(item.actual)")
                
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
