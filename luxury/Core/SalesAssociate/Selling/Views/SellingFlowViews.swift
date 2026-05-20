//
//  SellingFlowViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct LookBuilderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selected = ["Rolex Submariner", "Bottega Jodie", "Cartier Love Bracelet"]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                FlowHeader(title: "Look Builder", dismiss: dismiss)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("AI RECOMMENDED SET")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        ForEach(selected, id: \.self) { item in
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.gold08)
                                    .frame(width: 48, height: 48)
                                    .overlay(Image(systemName: "sparkles").foregroundStyle(AppColors.gold))
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item)
                                        .font(AppFonts.serif(size: 17, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text("Matched to client preferences and wishlist gaps")
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                Spacer()
                                StatusBadge(text: "Fit", status: .success)
                            }
                            .padding(14)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        CustomButton(title: "Save Look to Wishlist", icon: AnyView(Image(systemName: "heart.fill")), action: {})
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct RemoteSellingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appointmentLinked = true
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                FlowHeader(title: "Remote Selling", dismiss: dismiss)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        StatusBadge(text: appointmentLinked ? "Appointment Linked" : "Draft", status: appointmentLinked ? .success : .pending)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Private video consultation")
                                .font(AppFonts.serif(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Client receives curated products, split tender estimate, and secure payment handoff placeholder.")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Toggle("Link to Rahul Bajaj 2:30 PM appointment", isOn: $appointmentLinked)
                            .font(AppFonts.sansSerif(size: 13))
                            .foregroundStyle(AppColors.text)
                            .toggleStyle(LuxuryToggleStyle())
                            .padding(14)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        CustomButton(title: "Create Remote Appointment", icon: AnyView(Image(systemName: "video.fill")), action: {})
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct FlowHeader: View {
    let title: String
    let dismiss: DismissAction
    
    var body: some View {
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
    }
}
