//
//  DashboardView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct DashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(Router.self) private var router
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                CustomHeader(title: "Dashboard")

                if viewModel.isOffline {
                    HStack(spacing: 10) {
                        Image(systemName: "wifi.slash")
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.error)
                        Text("Offline · Last synced \(viewModel.lastSyncedText)")
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.error)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(AppColors.error.opacity(0.08))
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        VStack(alignment: .leading, spacing: 16) {
                            Text("TODAY'S PERFORMANCE")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)

                            SalesTargetCard(
                                actual:             viewModel.todaySales,
                                target:             viewModel.salesTarget,
                                actualProgress:     viewModel.salesProgress,
                                pacingProgress:     viewModel.pacingProgress,
                                projectedSales:     viewModel.projectedSales,
                                pacingStatus:       viewModel.pacingStatus,
                                isTargetConfigured: viewModel.isTargetConfigured
                            )
                        }
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("PENDING APPROVALS")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                Spacer()
                                StatusBadge(text: "\(viewModel.pendingApprovals.count) Pending", status: .warning)
                            }
                            .padding(.horizontal, 24)

                            VStack(spacing: 12) {
                                ForEach(viewModel.pendingApprovals) { request in
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(request.clientName)
                                                    .font(AppFonts.serif(size: 18, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text("Requested by \(request.associateName)")
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text(request.amount)
                                                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                                                    .foregroundStyle(AppColors.gold)
                                                Text("\(request.discount) OFF")
                                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                                    .foregroundStyle(AppColors.error)
                                            }
                                        }

                                        HStack(spacing: 12) {
                                            Button("Reject") { viewModel.reject(request) }
                                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                                .foregroundStyle(AppColors.error)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(AppColors.error.opacity(0.1))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                            Button("Approve") { viewModel.approve(request) }
                                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                                .foregroundStyle(AppColors.background)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(AppColors.gold)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.gold15, lineWidth: 0.5)
                                    )
                                }
                            }
                            .padding(.horizontal, 24)

                            HStack(spacing: 10) {
                                CustomOutlineButton(
                                    title: "Refund Queue",
                                    icon: AnyView(Image(systemName: "arrow.uturn.backward.circle")),
                                    action: { router.push(BMRoute.refundApproval) }
                                )
                                CustomOutlineButton(
                                    title: "Write-Off",
                                    icon: AnyView(Image(systemName: "exclamationmark.triangle")),
                                    action: { router.push(BMRoute.writeOffApproval) }
                                )
                            }
                            .padding(.horizontal, 24)
                        }

                        VStack(alignment: .leading, spacing: 16) {
                            Text("UPCOMING APPOINTMENTS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)

                            VStack(spacing: 1) {
                                ForEach(viewModel.appointments) { appointment in
                                    Button(action: {
                                        router.presentFullScreen(BMRoute.appointmentDetail(appointment))
                                    }) {
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(appointment.time)
                                                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                                    .foregroundStyle(AppColors.gold)
                                                Text(appointment.type.uppercased())
                                                    .font(AppFonts.sansSerif(size: 8, weight: .bold))
                                                    .foregroundStyle(AppColors.tertiary)
                                            }
                                            .frame(width: 70, alignment: .leading)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(appointment.clientName)
                                                    .font(AppFonts.serif(size: 17, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text("Advisor: \(appointment.advisorName)")
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.secondary)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 18)
                                        .background(AppColors.surface)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        CustomButton(title: "Logout", action: { coordinator.logout() })
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
                .task {
                    viewModel.startRealTimeUpdates()
                }
                .onDisappear {
                    viewModel.stopRealTimeUpdates()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environment(AppCoordinator())
            .environment(Router())
    }
}
