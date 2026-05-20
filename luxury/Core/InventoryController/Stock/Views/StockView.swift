//
//  StockView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct StockView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = StockViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Stock")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            Button(action: {
                                router.push(ICRoute.stockSearch)
                            }) {
                                MetricCard(title: "Total SKU", value: viewModel.totalItems, subtitle: "Tap to Search", icon: "box.truck")
                            }
                            .buttonStyle(.plain)
                            
                            MetricCard(title: "Low Stock", value: viewModel.lowStockCount, subtitle: "Action Required", icon: "exclamationmark.triangle")
                        }
                        .padding(.horizontal, 20)
                        
                        CustomOutlineButton(title: "Serialization & CoA", icon: AnyView(Image(systemName: "doc.badge.gearshape")), action: {
                            router.push(ICRoute.serialCertificate)
                        })
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("LIVE INVENTORY ALERTS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(viewModel.alerts) { alert in
                                    Button(action: {
                                        router.push(ICRoute.stockDetail(alert))
                                    }) {
                                        HStack(spacing: 16) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(alert.itemName)
                                                    .font(AppFonts.serif(size: 17, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                Text(alert.sku)
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 6) {
                                                StatusBadge(text: alert.currentQty == 0 ? "Out of Stock" : "\(alert.currentQty) Left", status: alert.status)
                                            }
                                        }
                                        .padding(16)
                                        .background(AppColors.surface)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
