//
//  AuditView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct AuditView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(Router.self) private var router
    @State private var viewModel = AuditViewModel()
    
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
                                if count.status == "Due" {
                                    router.presentFullScreen(ICRoute.activeAudit)
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
                                    StatusBadge(text: count.status, status: count.badgeStatus)
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
                            Button(action: { router.presentFullScreen(ICRoute.auditDetail(count)) }) {
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
                                    StatusBadge(text: count.status, status: count.badgeStatus)
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
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
