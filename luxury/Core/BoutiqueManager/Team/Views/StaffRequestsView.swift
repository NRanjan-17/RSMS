//
//  StaffRequestsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI

struct StaffRequestsView: View {
    @State private var viewModel = TeamViewModel()
    @State private var selectedAssociate: SalesAssociate?
    @State private var selectedController: InventoryController?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("STAFF APPLICATIONS")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.gold)
                    .kerning(1.5)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(AppColors.gold).frame(maxWidth: .infinity)
                    Spacer()
                } else if viewModel.pendingAssociates.isEmpty && viewModel.pendingControllers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.tertiary)
                        Text("No pending staff requests")
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(viewModel.pendingAssociates) { request in
                                staffRequestRow(name: request.name, role: "Sales Associate", date: request.createdAt, request: request)
                            }
                            ForEach(viewModel.pendingControllers) { request in
                                staffRequestRow(name: request.name, role: "Inventory Controller", date: request.createdAt, request: request)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            viewModel.fetchData()
        }
        .sheet(item: $selectedAssociate) { associate in
            RequestDetailSheet(
                title: associate.name,
                subtitle: "Sales Associate",
                details: [
                    ("Email", associate.email),
                    ("Address", associate.address),
                    ("Status", associate.status.rawValue.capitalized)
                ],
                avatarUrl: associate.avatarUrl,
                resumeUrl: associate.resumeUrl,
                isApproving: viewModel.actionStaffId == associate.id,
                isRejecting: viewModel.actionStaffId == associate.id,
                onApprove: {
                    viewModel.approveAssociate(associate) {
                        selectedAssociate = nil
                    }
                },
                onReject: {
                    viewModel.rejectAssociate(associate) {
                        selectedAssociate = nil
                    }
                }
            )
        }
        .sheet(item: $selectedController) { controller in
            RequestDetailSheet(
                title: controller.name,
                subtitle: "Inventory Controller",
                details: [
                    ("Email", controller.email),
                    ("Address", controller.address),
                    ("Status", controller.status.rawValue.capitalized)
                ],
                avatarUrl: controller.avatarUrl,
                resumeUrl: controller.resumeUrl,
                isApproving: viewModel.actionStaffId == controller.id,
                isRejecting: viewModel.actionStaffId == controller.id,
                onApprove: {
                    viewModel.approveController(controller) {
                        selectedController = nil
                    }
                },
                onReject: {
                    viewModel.rejectController(controller) {
                        selectedController = nil
                    }
                }
            )
        }
    }
    
    private func staffRequestRow(name: String, role: String, date: Date, request: Any) -> some View {
        Button(action: {
            if let associate = request as? SalesAssociate {
                selectedAssociate = associate
            } else if let controller = request as? InventoryController {
                selectedController = controller
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.gold08)
                        .frame(width: 44, height: 44)
                    Text(String(name.prefix(1)))
                        .font(AppFonts.serif(size: 18, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(AppFonts.serif(size: 18, weight: .medium))
                        .foregroundStyle(AppColors.text)
                    Text("\(role) · \(RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date()))")
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
