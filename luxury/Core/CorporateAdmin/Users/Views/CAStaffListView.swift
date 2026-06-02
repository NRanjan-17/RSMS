//
//  CAStaffListView.swift
//  luxury
//

import SwiftUI

struct CAStaffListView: View {
    @State private var viewModel = CAStaffListViewModel()
    @Environment(Router.self) private var router
    @State private var searchText = ""
    
    var filteredStaff: [StaffModel] {
        if searchText.isEmpty {
            return viewModel.staffMembers
        } else {
            return viewModel.staffMembers.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(AppColors.gold)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error).font(AppFonts.sansSerif(size: 14)).foregroundStyle(AppColors.error).padding(40)
                    Spacer()
                } else if filteredStaff.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
                            .font(AppFonts.sansSerif(size: 40))
                            .foregroundStyle(AppColors.tertiary)
                        Text(searchText.isEmpty ? "No staff members found" : "No staff matches '\(searchText)'")
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredStaff) { staff in
                                Button(action: {
                                    router.push(CARoute.staffDetail(staff))
                                }) {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(staff.name)
                                                .font(AppFonts.serif(size: 18, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            Text("\(staff.role.displayName) · \(staff.location.isEmpty ? "No Location" : staff.location)")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(AppFonts.sansSerif(size: 12))
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
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name, email, or boutique")
        .navigationTitle("Global Staff")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchStaff()
        }
    }
}
