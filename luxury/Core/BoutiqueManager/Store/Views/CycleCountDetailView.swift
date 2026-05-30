//
//  CycleCountDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct CycleCountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @State private var viewModel = AuditSignoffViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
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

                        VStack(alignment: .leading, spacing: 12) {
                            Text("NEED TO CORRECT A COUNT?")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)

                            Text("Open stock reconciliation to scan barcodes or QR codes, compare expected versus scanned quantities, and submit inventory corrections.")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)

                            CustomOutlineButton(
                                title: "Open Reconciliation",
                                icon: AnyView(Image(systemName: "barcode.viewfinder")),
                                action: {
                                    dismiss()
                                    router.push(BMRoute.stockReconciliation)
                                }
                            )
                        }
                        .padding(20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.gold15, lineWidth: 1)
                        )
                        .padding(.horizontal, 24)

                        CustomButton(title: "Sign-off Audit", action: { dismiss() })
                            .padding(.horizontal, 24)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Audit Sign-off")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
