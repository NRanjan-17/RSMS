//
//  MetricCard.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct MetricCard: View {
    let title: LocalizedStringKey
    let value: String
    let subtitle: LocalizedStringKey?
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(AppFonts.sansSerif(size: 20))
                    .foregroundStyle(AppColors.gold)
                    .accessibilityHidden(true)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppFonts.serif(size: 24, weight: .bold))
                    .foregroundStyle(AppColors.text)
                
                Text(title)
                    .textCase(.uppercase)
                    .font(AppFonts.sansSerif(size: 10, weight: .semibold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1)
            }
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFonts.sansSerif(size: 11))
                    .foregroundStyle(AppColors.gold70)
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.gold15, lineWidth: 0.5)
        )
        .accessibilityElement(children: .combine)
    }
}
