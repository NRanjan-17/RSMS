//
//  ManagerApprovalViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct RefundApprovalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state: MockApprovalState = .waiting
    
    var body: some View {
        ManagerDecisionView(
            title: "Refund Approval",
            heading: "Refund ₹2,45,000",
            detail: "Rahul Bajaj · Bottega Veneta The Jodie · Receipt verified · Tax-free documents attached",
            state: $state,
            dismiss: dismiss
        )
    }
}

struct WriteOffApprovalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state: MockApprovalState = .waiting
    
    var body: some View {
        ManagerDecisionView(
            title: "Write-Off Approval",
            heading: "Inventory write-off ₹8,20,000",
            detail: "Cycle Count CC-2026-05 · 3 variance items · Recount completed · Audit trail locked",
            state: $state,
            dismiss: dismiss
        )
    }
}

private struct ManagerDecisionView: View {
    let title: String
    let heading: String
    let detail: String
    @Binding var state: MockApprovalState
    let dismiss: DismissAction
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 44, height: 44)
                    }
                    Text(title)
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        StatusBadge(text: state.rawValue, status: state == .approved ? .success : state == .rejected ? .error : .pending)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text(heading)
                                .font(AppFonts.serif(size: 24, weight: .medium))
                                .foregroundStyle(.white)
                            Text(detail)
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("IMMUTABLE AUDIT PREVIEW")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            HStack {
                                Image(systemName: "lock.shield")
                                    .foregroundStyle(AppColors.gold)
                                Text("Decision timestamp, manager identity, and request snapshot will be stored with the local mock record.")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        HStack(spacing: 12) {
                            CustomOutlineButton(title: "Reject", icon: AnyView(Image(systemName: "xmark.circle")), action: {
                                state = .rejected
                            })
                            CustomButton(title: "Approve", icon: AnyView(Image(systemName: "checkmark.circle")), action: {
                                state = .approved
                            })
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
