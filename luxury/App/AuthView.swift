//
//  AuthView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct AuthView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showLogin = false
    @State private var selectedRole: UserRole = .salesAssociate

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            if !showLogin {
                RoleSelectionScreenView(onRoleSelected: { role in
                    print("DEBUG: Role selected in AuthView: \(role.rawValue)")
                    selectedRole = role
                    coordinator.routingService.intendedRole = role
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showLogin = true
                    }
                })
                .transition(.move(edge: .leading).combined(with: .opacity))
            } else {
                AuthenticationView(
                    selectedRole: selectedRole,
                    onBack: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showLogin = false
                        }
                    },
                    onSignInSuccess: {
                        print("DEBUG: onSignInSuccess callback triggered in AuthView")
                        Task {
                            let session = await AuthService().getCurrentSession()
                            print("DEBUG: Explicitly updating route in AuthView onSignInSuccess")
                            await coordinator.routingService.updateRoute(for: session)
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
            }
        }
    }
}

private struct RoleSelectionScreenView: View {
    var onRoleSelected: (UserRole) -> Void
    @State private var selectedRoleId: String = "ca"
    
    let roles = [
        (id: "ca", title: "Corporate Admin", sub: "Analytics · Users · Config", init: "CA", role: UserRole.corporateAdmin),
        (id: "bm", title: "Boutique Manager", sub: "Dashboard · Team · Store", init: "BM", role: UserRole.boutiqueManager),
        (id: "sa", title: "Sales Associate", sub: "Clienteling · POS · Selling", init: "SA", role: UserRole.salesAssociate),
        (id: "ic", title: "Inventory Controller", sub: "RFID · Transfers · Audit", init: "IC", role: UserRole.inventoryController)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 62)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("AUTHENTICATED · SELECT ROLE")
                    .font(AppFonts.sansSerif(size: 10))
                    .foregroundStyle(AppColors.gold)
                    .kerning(2.5)
                    .padding(.bottom, 14)
                
                Text("Select your\nworkspace.")
                    .font(AppFonts.serif(size: 38, weight: .regular))
                    .foregroundStyle(AppColors.text)
                    .lineSpacing(0)
                    .padding(.bottom, 8)
                
                Text("Your permissions and dashboard\nare tailored to your role.")
                    .font(AppFonts.sansSerif(size: 13, weight: .light))
                    .foregroundStyle(AppColors.secondary)
                    .lineSpacing(4)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 10) {
                ForEach(roles, id: \.id) { role in
                    let active = selectedRoleId == role.id
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedRoleId = role.id
                        }
                    }) {
                        HStack(spacing: 14) {
                            Text(role.`init`)
                                .font(AppFonts.serif(size: 16, weight: .semibold))
                                .foregroundStyle(active ? AppColors.background : AppColors.gold)
                                .kerning(1)
                                .frame(width: 48, height: 48)
                                .background(active ? AppColors.gold : AppColors.gold08)
                                .clipShape(RoundedRectangle(cornerRadius: 13))
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(role.title)
                                    .font(AppFonts.serif(size: 21, weight: .medium))
                                    .foregroundStyle(AppColors.text)
                                
                                Text(role.sub)
                                    .font(AppFonts.sansSerif(size: 11, weight: .light))
                                    .foregroundStyle(active ? AppColors.gold70 : AppColors.secondary)
                                    .kerning(0.3)
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(active ? Color.clear : AppColors.tertiary, lineWidth: 1)
                                    .frame(width: 22, height: 22)
                                
                                if active {
                                    Circle()
                                        .fill(AppColors.gold)
                                        .frame(width: 22, height: 22)
                                    
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.background)
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 18)
                        .background(active ? AppColors.gold08 : AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(active ? AppColors.gold : AppColors.gold15, lineWidth: active ? 1 : 0.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            VStack(spacing: 0) {
                CustomButton(
                    title: "Continue",
                    icon: AnyView(Image(systemName: "arrow.right").font(.system(size: 14, weight: .semibold))),
                    action: {
                        if let selected = roles.first(where: { $0.id == selectedRoleId }) {
                            onRoleSelected(selected.role)
                        }
                    }
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }
}
