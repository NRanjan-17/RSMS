//
//  TeamView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct TeamView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = TeamViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("MAY 2025")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(2)
                                Text("Team")
                                    .font(AppFonts.serif(size: 32, weight: .semibold))
                                    .foregroundStyle(AppColors.text)
                            }
                            Spacer()
                            Button(action: {}) {
                                Text("Schedule")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.gold)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(AppColors.gold08)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 14)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("STORE MONTHLY TARGET")
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.secondary)
                                        .kerning(1.5)
                                    Text(viewModel.storeTarget)
                                        .font(AppFonts.serif(size: 30, weight: .medium))
                                        .foregroundStyle(AppColors.gold)
                                    Text("of \(viewModel.storeTotal)")
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.secondary)
                                        .padding(.top, 2)
                                }
                                Spacer()
                                Text("\(Int(viewModel.storePct * 100))%")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(AppColors.gold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(AppColors.gold08)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            
                            ProgressView(value: viewModel.storePct)
                                .progressViewStyle(LuxuryProgressStyle())
                            
                            HStack {
                                Text("5/6 staff on floor")
                                Spacer()
                                Text("+18% vs last month")
                                    .foregroundStyle(AppColors.gold)
                            }
                            .font(AppFonts.sansSerif(size: 11))
                            .foregroundStyle(AppColors.secondary)
                            .padding(.top, 12)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        HStack {
                            Text("STAFF PERFORMANCE")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            Spacer()
                            Text("Full report")
                                .font(AppFonts.sansSerif(size: 11, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        VStack(spacing: 10) {
                            let staff = viewModel.staff
                            ForEach(staff, id: \.id) { s in
                                Button(action: {
                                    router.presentFullScreen(BMRoute.staffPerformanceDetail(s))
                                }) {
                                    VStack(spacing: 10) {
                                        HStack(alignment: .center, spacing: 10) {
                                            ZStack {
                                                if let avatarUrl = s.avatarUrl, let url = URL(string: avatarUrl) {
                                                    AsyncImage(url: url) { image in
                                                        image.resizable().aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        AppColors.gold08
                                                    }
                                                    .frame(width: 38, height: 38)
                                                    .clipShape(RoundedRectangle(cornerRadius: 11))
                                                } else {
                                                    RoundedRectangle(cornerRadius: 11)
                                                        .fill(AppColors.gold08)
                                                        .frame(width: 38, height: 38)
                                                    Text(s.initials)
                                                        .font(AppFonts.serif(size: 13, weight: .semibold))
                                                        .foregroundStyle(AppColors.gold)
                                                }
                                                
                                                Circle()
                                                    .fill(s.live ? AppColors.success : AppColors.tertiary)
                                                    .frame(width: 9, height: 9)
                                                    .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                                                    .offset(x: 18, y: 18)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(s.name)
                                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text("\(s.clients) clients · \(s.live ? "On Floor" : "Off Shift")")
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 4) {
                                                Text(s.rev)
                                                    .font(AppFonts.serif(size: 15, weight: .semibold))
                                                    .foregroundStyle(AppColors.gold)
                                                Text("of \(s.target)")
                                                    .font(AppFonts.sansSerif(size: 10))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                        }
                                        
                                        HStack(spacing: 8) {
                                            ProgressView(value: s.pct)
                                                .progressViewStyle(LuxuryProgressStyle(height: 3))
                                            
                                            let pctVal = Int(s.pct * 100)
                                            let pctColor = s.pct >= 0.7 ? AppColors.success : (s.pct >= 0.4 ? AppColors.gold : AppColors.warning)
                                            Text("\(pctVal)%")
                                                .font(AppFonts.sansSerif(size: 11, weight: .medium))
                                                .foregroundStyle(pctColor)
                                                .frame(width: 30, alignment: .trailing)
                                        }
                                    }
                                    .padding(14)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 14)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
