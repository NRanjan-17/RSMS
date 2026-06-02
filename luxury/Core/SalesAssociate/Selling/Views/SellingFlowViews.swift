//
//  SellingFlowViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

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
                        StatusBadge(text: appointmentLinked ? LocalizedStringKey("Appointment Linked") : LocalizedStringKey("Draft"), status: appointmentLinked ? .success : .pending)
                        
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
                        
                        Toggle("Link to Unknown Client 2:30 PM appointment", isOn: $appointmentLinked)
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct FlowHeader: View {
    let title: String
    let dismiss: DismissAction
    
    var body: some View {
    }
}
