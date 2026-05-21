//
//  TeamView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct TeamView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = TeamViewModel()
    
    @State private var showInviteSheet = false
    @State private var inviteEmail = ""
    @State private var inviteRole = StaffRole.salesAssociate
    @State private var isInviting = false
    @State private var inviteError: String?
    
    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("Team")
                        .font(AppFonts.serif(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            inviteEmail = ""
                            inviteRole = .salesAssociate
                            inviteError = nil
                            showInviteSheet = true
                        }) {
                            Label("Invite Staff", systemImage: "envelope.badge")
                        }
                        
                        Button(action: {
                            router.push(BMRoute.pendingStaff)
                        }) {
                            Label("Review Responses", systemImage: "bell")
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.gold)
                                .frame(width: 44, height: 44)
                                .background(.ultraThinMaterial, in: Circle())
                            
                            if viewModel.pendingStaffCount > 0 {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.error)
                                        .frame(width: 18, height: 18)
                                    Text("\(viewModel.pendingStaffCount)")
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
                        
                        TextField("Search employees…", text: $vm.searchText)
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
                            ActiveEmployeesListView(viewModel: viewModel)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(isPresented: $showInviteSheet) {
            NavigationStack {
                ZStack {
                    AppColors.background.ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Staff Email")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.secondary)
                            
                            TextField("Enter email address", text: $inviteEmail)
                                .font(AppFonts.sansSerif(size: 16))
                                .foregroundStyle(AppColors.text)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .padding()
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.gold15, lineWidth: 0.5)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Role")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.secondary)
                            
                            Picker("Role", selection: $inviteRole) {
                                Text("Sales Associate").tag(StaffRole.salesAssociate)
                                Text("Inventory Controller").tag(StaffRole.inventoryController)
                            }
                            .pickerStyle(.segmented)
                            .padding(4)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 24)
                        
                        if let inviteError {
                            Text(inviteError)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.error)
                                .padding(.horizontal, 24)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 24)
                }
                .navigationTitle("Invite Staff")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showInviteSheet = false
                        }
                        .foregroundStyle(AppColors.gold)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if isInviting {
                            ProgressView().tint(AppColors.gold)
                        } else {
                            Button("Send") {
                                sendInvitation()
                            }
                            .disabled(inviteEmail.isEmpty)
                            .foregroundStyle(inviteEmail.isEmpty ? AppColors.tertiary : AppColors.gold)
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func sendInvitation() {
        guard !inviteEmail.isEmpty else { return }
        isInviting = true
        inviteError = nil
        
        Task {
            do {
                try await viewModel.inviteStaff(email: inviteEmail, role: inviteRole)
                await MainActor.run {
                    isInviting = false
                    showInviteSheet = false
                }
            } catch {
                await MainActor.run {
                    isInviting = false
                    inviteError = error.localizedDescription
                }
            }
        }
    }
}

private struct ActiveEmployeesListView: View {
    let viewModel: TeamViewModel
    @Environment(Router.self) private var router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if viewModel.approvedStaff.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.tertiary)
                    Text("No active employees yet")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else if viewModel.filteredStaff.isEmpty {
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
                    ForEach(viewModel.filteredStaff) { employee in
                        Button(action: {
                            router.push(BMRoute.staffDetail(employee))
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.gold08)
                                        .frame(width: 44, height: 44)
                                    Text(String(employee.name.prefix(1)))
                                        .font(AppFonts.serif(size: 18, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(employee.name)
                                        .font(AppFonts.serif(size: 18, weight: .medium))
                                        .foregroundStyle(AppColors.text)
                                    Text("\(employee.role.displayName) · \(employee.employeeId) · \(employee.phone)")
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
                .padding(.bottom, 24)
            }
        }
    }
}
