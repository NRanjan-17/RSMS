//
//  AuditDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct AuditDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    let audit: RSMSCycleCount
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Audit Details")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(audit.scope.uppercased())
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(1.5)
                                Spacer()
                                StatusBadge(text: audit.status, status: audit.badgeStatus)
                            }
                            
                            Text(audit.title)
                                .font(AppFonts.serif(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Text("Scheduled for \(audit.date)")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("INSTRUCTIONS")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                BulletPoint(text: "Ensure all items in \(audit.scope) are tagged.")
                                BulletPoint(text: "Use the RFID scanner for large quantities.")
                                BulletPoint(text: "Scan QR/Barcodes for items with damaged tags.")
                            }
                        }
                        .padding(20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREPARATION CHECKLIST")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ChecklistRow(text: "Device Battery > 80%", checked: true)
                                ChecklistRow(text: "Scanner Synced", checked: true)
                                ChecklistRow(text: "Floor area cleared", checked: false)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                VStack {
                    CustomButton(title: "Begin Audit Scan", icon: AnyView(Image(systemName: "barcode.viewfinder")), action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            router.presentFullScreen(ICRoute.activeAudit(audit))
                        }
                    })
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct BulletPoint: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle().fill(AppColors.gold).frame(width: 4, height: 4).padding(.top, 6)
            Text(text)
                .font(AppFonts.sansSerif(size: 13))
                .foregroundStyle(AppColors.text)
                .lineSpacing(4)
        }
    }
}

private struct ChecklistRow: View {
    let text: String
    let checked: Bool
    var body: some View {
        HStack {
            Text(text)
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(checked ? AppColors.text : AppColors.secondary)
            Spacer()
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(checked ? AppColors.success : AppColors.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(AppColors.surface)
    }
}

#Preview {
    AuditDetailView(audit: RSMSCycleCount(
        title: "High Value Zone",
        date: "Today",
        scope: "Watches",
        status: "Due",
        badgeStatus: .warning
    ))
    .environment(Router())
}
