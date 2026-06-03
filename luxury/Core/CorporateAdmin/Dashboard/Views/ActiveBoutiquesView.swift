//
//  ActiveBoutiquesView.swift
//  luxury
//

import SwiftUI

struct ActiveBoutiquesView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = GlobalAnalyticsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text("Active Boutiques")
                    .font(AppFonts.serif(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                // Invisible spacer for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .opacity(0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 12)
            .background(AppColors.background)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(viewModel.boutiquePerformance) { boutique in
                        Button(action: {
                            router.push(CARoute.boutiqueDetail(boutique))
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(boutique.name)
                                        .font(AppFonts.serif(size: 17, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text("\(boutique.city) · \(boutique.managerName)")
                                        .font(AppFonts.sansSerif(size: 12))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.tertiary)
                            }
                            .padding(18)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
            .refreshable {
                viewModel.fetchData()
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.fetchData()
        }
    }
}
