//
//  AfterSalesViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct AfterSalesIntakeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var serial = "RLX-126610LN-8M2"
    @State private var issue = "Bracelet sizing and clasp stiffness"
    @State private var photoAttached = false
    @State private var created = false
    
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
                    Text("After-Sales Intake")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        StatusBadge(text: created ? "Ticket Created" : "Photo Required", status: created ? .success : .warning)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CLIENT")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            Text("Rahul Bajaj · UHNW · Appointment linked")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 12) {
                            TextField("Serial or manual item entry", text: $serial)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            TextField("Issue and condition notes", text: $issue, axis: .vertical)
                                .lineLimit(4, reservesSpace: true)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            Toggle("Condition photos attached", isOn: $photoAttached)
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.text)
                                .toggleStyle(LuxuryToggleStyle())
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WARRANTY")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            HStack {
                                StatusBadge(text: "Active", status: .success)
                                Text("Warranty valid until 24 Nov 2027")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        CustomButton(title: created ? "Ticket RSMS-AS-1042 Created" : "Create Service Ticket", icon: AnyView(Image(systemName: "wrench.and.screwdriver")), action: {
                            created = photoAttached
                        })
                        .disabled(!photoAttached)
                        .opacity(photoAttached ? 1 : 0.45)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct AfterSalesTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let ticket = AfterSalesTicket(client: "Rahul Bajaj", item: "Rolex Submariner Date", serial: "RLX-126610LN-8M2", issue: "Bracelet sizing", stage: .inspection, photoRequired: false)
    
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
                    Text("Ticket Tracking")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ticket.item)
                                .font(AppFonts.serif(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                            Text("\(ticket.client) · \(ticket.serial)")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.secondary)
                            StatusBadge(text: ticket.stage.rawValue, status: .pending)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 12) {
                            ForEach(AfterSalesStage.allCases, id: \.self) { stage in
                                HStack(spacing: 12) {
                                    Image(systemName: stage == ticket.stage ? "clock.fill" : "checkmark.circle.fill")
                                        .foregroundStyle(stage == ticket.stage ? AppColors.gold : AppColors.success)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(stage.rawValue)
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text(stage == ticket.stage ? "Current stage" : "Logged in immutable ticket timeline")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
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
