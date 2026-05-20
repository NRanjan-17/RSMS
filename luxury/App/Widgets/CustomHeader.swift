//
//  CustomHeader.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct CustomHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppFonts.serif(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(AppColors.background)
    }
}
