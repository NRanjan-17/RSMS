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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("\(viewModel.store) · TUE 13 MAY")
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
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("TODAY'S REVENUE")
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.secondary)
                                        .kerning(1.5)
                                    Text(CurrencyManager.shared.format(amount: viewModel.revenue))
                                        .font(AppFonts.serif(size: 36, weight: .medium))
                                        .foregroundStyle(AppColors.gold)
                                        .kerning(-0.5)
                                    Text("of \\(CurrencyManager.shared.format(amount: viewModel.target)) target")
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("TODAY'S APPOINTMENTS")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.8)
                                Spacer()
                                Button(action: {
                                    router.push(SARoute.appointmentList)
                                }) {
                                    Text("3 remaining")
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.gold)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 8) {
                                let appts = viewModel.appointments
                                ForEach(appts, id: \.id) { a in
                                    Button(action: {
                                        router.push(SARoute.appointmentList)
                                    }) {
                                        HStack(spacing: 12) {
                                            Text(a.formattedTime)
                                                .font(AppFonts.sansSerif(size: 10, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(AppColors.gold08)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                            
                                            ZStack {
                                                Circle()
                                                    .fill(AppColors.gold08)
                                                Text(String(a.client?.name.prefix(1) ?? "U"))
                                                    .font(AppFonts.serif(size: 16, weight: .bold))
                                                    .foregroundStyle(AppColors.gold)
                                            }
                                            .frame(width: 40, height: 40)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack {
                                                    Text(a.client?.name ?? "Unknown Client")
                                                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                        .foregroundStyle(AppColors.text)
                                                }
                                                Text(a.appointmentType)
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            .foregroundStyle(AppColors.secondary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("RECENT CLIENTS")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.8)
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        saAppState.selectedTab = .clients
                                    }
                                }) {
                                    Text("See all")
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.gold)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                let clients = viewModel.recentClients
                                ForEach(clients, id: \.id) { cl in
                                    Button(action: {
                                        let dummyClient = Client(name: cl.name, tier: cl.tier == "UHNW" ? .uhnw : .vip, lastVisit: cl.lastVisit, ltv: cl.ltv, initial: cl.initial)
                                        router.push(SARoute.clientProfile(dummyClient))
                                    }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 11)
                                                    .fill(AppColors.gold08)
                                                    .frame(width: 38, height: 38)
                                                Text(cl.initial)
                                                    .font(AppFonts.serif(size: 13, weight: .semibold))
                                                    .foregroundStyle(AppColors.gold)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                HStack(spacing: 6) {
                                                    Text(cl.name)
                                                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                        .foregroundStyle(AppColors.text)
                                                    StatusBadge(text: cl.tier, status: cl.tier == "UHNW" ? .success : .neutral)
                                                }
                                                Text("Last visit \(cl.lastVisit) · LTV \(CurrencyManager.shared.formatCompact(amount: cl.ltv))")
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 13)
                                        .background(AppColors.surface)
                                        .overlay(
                                            VStack {
                                                Spacer()
                                                if cl.id != clients.last?.id {
                                                    Divider().background(AppColors.gold08).padding(.horizontal, 14)
                                                }
                                            }
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 18)
                        
                        // MARK: - Security
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SECURITY")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            NavigationLink(destination: SecuritySettingsView()) {
                                HStack {
                                    Image(systemName: "lock.shield.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(AppColors.gold)
                                    Text("Security Settings")
                                        .font(AppFonts.sansSerif(size: 15))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                                .padding(16)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 18)
                        
                        // MARK: - Support & Policies
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SUPPORT & POLICIES")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            Button(action: {
                                router.push(SARoute.exchangePolicy)
                            }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(AppColors.gold)
                                    Text("Exchange Policy")
                                        .font(AppFonts.sansSerif(size: 15))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                                .padding(16)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 18)
                        
                        CustomButton(title: "Logout", action: { showLogoutAlert = true })
                            .padding(.horizontal, 24)
                            .padding(.top, 30)
                            .padding(.bottom, 60)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchAppointments()
        }
        .toolbar(.hidden, for: .navigationBar)
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
