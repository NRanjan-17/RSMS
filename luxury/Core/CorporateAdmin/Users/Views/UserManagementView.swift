//
//  UserManagementView.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI

struct UserManagementView: View {
    @Bindable var viewModel: UserManagementViewModel
    @Environment(Router.self) private var router
    
    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Boutique Management")
                        .font(AppFonts.serif(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        router.push(CARoute.pendingBoutiques)
                    }) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(AppColors.gold)
                                .frame(width: 44, height: 44)
                            
                            if !viewModel.pendingBoutiques.isEmpty {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.error)
                                        .frame(width: 18, height: 18)
                                    Text("\(viewModel.pendingBoutiques.count)")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                                .offset(x: 10, y: 0)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(AppColors.background)
                
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.tertiary)
                        
                        TextField("Search boutiques…", text: $vm.searchText)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold15, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(AppColors.gold)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        Text(error).font(AppFonts.sansSerif(size: 14)).foregroundStyle(AppColors.error).padding(40)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            ApprovedBoutiquesListView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

private struct ApprovedBoutiquesListView: View {
    @Bindable var viewModel: UserManagementViewModel
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if viewModel.approvedBoutiques.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.tertiary)
                    Text("No boutiques registered yet")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else if viewModel.filteredApprovedBoutiques.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.tertiary)
                    Text("No results matching \"\(viewModel.searchText)\"")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.filteredApprovedBoutiques) { boutique in
                        Button(action: {
                            router.push(CARoute.boutiqueDetail(boutique))
                        }) {
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(boutique.name)
                                        .font(AppFonts.serif(size: 18, weight: .medium))
                                        .foregroundStyle(AppColors.text)
                                    Text("\(boutique.managerName) · \(boutique.managerPhone) · \(boutique.city)")
                                        .font(AppFonts.sansSerif(size: 12))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppColors.tertiary)
                            }
                            .padding(18)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}
