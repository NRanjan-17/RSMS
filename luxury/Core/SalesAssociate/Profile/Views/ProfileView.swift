//
//  ProfileView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(SalesAssociateAppState.self) private var saAppState
    @Environment(Router.self) private var router
    @State private var viewModel = SAProfileViewModel()
    @State private var showLogoutAlert = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(AppColors.gold)
                            .scaleEffect(1.2)
                        Spacer()
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            // My Profile Section
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(viewModel.store) · \(viewModel.role)")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(2)
                                    .textCase(.uppercase)
                                Text(viewModel.greeting)
                                    .font(AppFonts.serif(size: 30, weight: .light).italic())
                                    .foregroundStyle(AppColors.text)
                                Text(viewModel.name)
                                    .font(AppFonts.serif(size: 30, weight: .semibold))
                                    .foregroundStyle(AppColors.text)
                                Text("ID: \(viewModel.employeeId)")
                                    .font(AppFonts.sansSerif(size: 13))
                                    .foregroundStyle(AppColors.secondary)
                                    .padding(.top, 4)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                            
                            // My Performance Section
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("MY PERFORMANCE")
                                            .font(AppFonts.sansSerif(size: 10))
                                            .foregroundStyle(AppColors.secondary)
                                            .kerning(1.5)
                                        Text(viewModel.personalSales)
                                            .font(AppFonts.serif(size: 36, weight: .medium))
                                            .foregroundStyle(AppColors.gold)
                                            .kerning(-0.5)
                                        Text(viewModel.salesGoal)
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                            .padding(.top, 2)
                                    }
                                    Spacer()
                                    Text("\(Int(viewModel.progress * 100))%")
                                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                        .foregroundStyle(AppColors.gold)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 5)
                                        .background(AppColors.gold08)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                                }
                                ProgressView(value: viewModel.progress)
                                    .progressViewStyle(LuxuryProgressStyle())
                                    
                                Divider().background(AppColors.gold15).padding(.vertical, 4)
                                
                                HStack {
                                    Text("ESTIMATED COMMISSIONS")
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.secondary)
                                        .kerning(1.5)
                                    Spacer()
                                    Text(viewModel.commissions)
                                        .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                        .foregroundStyle(AppColors.success)
                                }
                            }
                            .padding(18)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                            .padding(.top, 18)
                            
                            HStack(spacing: 10) {
                                StatChip(value: viewModel.statClients, label: "Clients")
                                StatChip(value: viewModel.statTransactions, label: "Transactions")
                                StatChip(value: viewModel.statAppts, label: "Appts")
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            
                            // My Schedule Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MY SCHEDULE")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.8)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 8) {
                                    ForEach(viewModel.upcomingShifts) { shift in
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(shift.date)
                                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text(shift.time)
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            Spacer()
                                            Text(shift.location)
                                                .font(AppFonts.sansSerif(size: 11, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 6)
                                                .background(AppColors.gold08)
                                                .clipShape(Capsule())
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                            
                            // App Preferences Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("PREFERENCES")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                    .padding(.horizontal, 24)
                                
                                VStack(spacing: 0) {
                                    SettingsRow(icon: "bell.fill", title: "Notifications")
                                    Divider().background(AppColors.gold08).padding(.horizontal, 16)
                                    SettingsRow(icon: "globe", title: "Language", value: "English")
                                }
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                            
                            // Store Information Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("STORE INFORMATION")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                    .padding(.horizontal, 24)
                                
                                Button(action: {
                                    router.push(SARoute.exchangePolicy)
                                }) {
                                    SettingsRow(icon: "doc.text.fill", title: "Exchange Policy")
                                }
                                .buttonStyle(.plain)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                            
                            // MARK: - Security
                            VStack(alignment: .leading, spacing: 16) {
                                Text("SECURITY")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                    .padding(.horizontal, 24)
                                
                                NavigationLink(destination: SecuritySettingsView()) {
                                    SettingsRow(icon: "lock.shield.fill", title: "Security Settings")
                                }
                                .buttonStyle(.plain)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                .padding(.horizontal, 24)
                            }
                            .padding(.top, 24)
                            
                            CustomButton(title: "Logout", action: { showLogoutAlert = true })
                                .padding(.horizontal, 24)
                                .padding(.top, 30)
                                .padding(.bottom, 60)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadProfileData()
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Logout", role: .destructive) {
                coordinator.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to logout?")
        }
    }
}

private struct StatChip: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFonts.serif(size: 27, weight: .medium))
                .foregroundStyle(AppColors.text)
            Text(label)
                .font(AppFonts.sansSerif(size: 10))
                .foregroundStyle(AppColors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(AppColors.gold)
                .frame(width: 24)
            Text(title)
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(.white)
            Spacer()
            if let value = value {
                Text(value)
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.tertiary)
        }
        .padding(16)
        .contentShape(Rectangle())
    }
}
