import SwiftUI

struct AuditView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(Router.self) private var router
    @State private var viewModel = AuditViewModel()
    @State private var showUpcomingToast = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Inventory Audit")
                
                List {
                    Section {
                        let counts = viewModel.scheduledCounts
                        ForEach(counts, id: \.id) { count in
                            Button(action: {
                                if count.status == "UPCOMING" {
                                    withAnimation { showUpcomingToast = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation { showUpcomingToast = false }
                                    }
                                } else if count.status == "SIGNED OFF" || count.status == "Signed Off" || count.status == "Submitted" {
                                    router.push(ICRoute.varianceReport(count))
                                } else {
                                    router.presentFullScreen(ICRoute.auditDetail(count))
                                }
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(count.title)
                                            .font(AppFonts.serif(size: 17, weight: .medium))
                                            .foregroundStyle(AppColors.text)
                                        HStack(spacing: 8) {
                                            Text(count.scope)
                                            Text("•")
                                            Text(count.date)
                                        }
                                        .font(AppFonts.sansSerif(size: 12))
                                        .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    StatusBadge(text: LocalizedStringKey(count.status), status: count.badgeStatus)
                                }
                            }
                            .listRowBackground(AppColors.surface)
                        }
                    } header: {
                        Text("SCHEDULED COUNTS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                    }
                    
                    Section {
                        let audits = viewModel.recentAudits
                        ForEach(audits, id: \.id) { count in
                            Button(action: { router.push(ICRoute.varianceReport(count)) }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(count.title)
                                            .font(AppFonts.serif(size: 17, weight: .medium))
                                            .foregroundStyle(AppColors.text)
                                        Text(count.date)
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    StatusBadge(text: LocalizedStringKey(count.status), status: count.badgeStatus)
                                }
                            }
                            .listRowBackground(AppColors.surface)
                        }
                    } header: {
                        Text("RECENT SIGN-OFFS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                    }

                }
                .scrollContentBackground(.hidden)
                .background(AppColors.background)
            }
            
            if showUpcomingToast {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppColors.warning)
                        Text("Audit locked until scheduled date.")
                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.warning, lineWidth: 1))
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
