//
//  ActiveAuditView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ActiveAuditView: View {
    @Environment(InventoryControllerAppState.self) private var icAppState
    @Environment(\.dismiss) private var dismiss
    @State private var showingBatchScanner = false
    @State private var tempScannedSerials: [String] = []

    private var viewModel: ActiveAuditViewModel {
        icAppState.activeAuditViewModel
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }

                    Text("Monthly Full Audit")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                VStack(spacing: 8) {
                    HStack {
                        Text("Audit Progress")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                        Spacer()
                        Text("\(viewModel.totalScanned)/\(viewModel.totalExpected) items")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                    }

                    ZStack(alignment: .leading) {
                        Capsule().fill(AppColors.surface).frame(height: 4)
                        Capsule().fill(AppColors.gold)
                            .frame(width: 325 * viewModel.progress, height: 4)
                            .animation(.spring(), value: viewModel.progress)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            StatusBadge(text: "Reason: \(viewModel.varianceReason)", status: .warning)
                            StatusBadge(text: viewModel.signoffState.rawValue, status: .pending)
                        }

                        Text("SCANNED ITEMS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.tertiary)
                            .kerning(1.5)

                        VStack(spacing: 1) {
                            ForEach(viewModel.scannedItems) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(item.ok ? .white : AppColors.error)
                                        Text(item.ok ? "MATCHED" : "UNEXPECTED SKU")
                                            .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                            .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                    }
                                    Spacer()
                                    Image(systemName: item.ok ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                        .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(AppColors.surface)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        if !viewModel.missingItems.isEmpty {
                            Text("MISSING ITEMS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.error)
                                .kerning(1.5)
                                .padding(.top, 8)

                            VStack(spacing: 1) {
                                ForEach(viewModel.missingItems, id: \.self) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(AppColors.secondary)
                                            Text("NOT SCANNED")
                                                .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                .foregroundStyle(AppColors.error)
                                        }
                                        Spacer()
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(AppColors.error)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surface)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                HStack(spacing: 10) {
                    CustomOutlineButton(title: "Scan Items", icon: AnyView(Image(systemName: "barcode.viewfinder")), action: {
                        tempScannedSerials = viewModel.scannedItems.map { $0.name }
                        showingBatchScanner = true
                    })
                    CustomButton(title: "Submit", icon: AnyView(Image(systemName: "checkmark.shield")), action: {
                        viewModel.submitForSignoff()
                        dismiss()
                    })
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showingBatchScanner) {
            BatchScannerSheet(
                scannedSerials: $tempScannedSerials,
                existingSerials: [],
                allowsDamageReporting: false,
                productName: "Inventory Count",
                expectedSerials: viewModel.expectedItems
            ) {
                showingBatchScanner = false
                viewModel.addScannedItems(names: tempScannedSerials)
            }
        }
    }
}
