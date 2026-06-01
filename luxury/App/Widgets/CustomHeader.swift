//
//  CustomHeader.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//  Modified by Antigravity on 01/06/26.
//

import SwiftUI

struct CustomHeader: View {
    let title: String
    var showBackButton: Bool = false
    var backAction: (() -> Void)? = nil
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            if showBackButton, let action = backAction {
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
            Text(title)
                .font(AppFonts.serif(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            Spacer()
            
            if let icon = trailingIcon, let action = trailingAction {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(AppColors.background)
    }
}
