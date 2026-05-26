//
//  StockView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct StockView: View {
    @Environment(Router.self) private var router
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = StockViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Stock")
                        .font(AppFonts.serif(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { coordinator.logout() }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.gold)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(AppColors.background)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            Button(action: {
                                router.push(ICRoute.stockSearch)
                            }) {
                                MetricCard(title: "Total SKU", value: viewModel.totalItems, subtitle: "Tap to Search", icon: "magnifyingglass")
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                router.push(ICRoute.barcodeScan)
                            }) {
                                MetricCard(title: "Scan", value: "Scan", subtitle: "Barcode Lookup", icon: "barcode.viewfinder")
                            }
                            .buttonStyle(.plain)
                            
                            MetricCard(title: "Low Stock", value: viewModel.lowStockCount, subtitle: "Action Required", icon: "exclamationmark.triangle")
                            
                            Button(action: {
                                router.push(ICRoute.sfsOrders)
                            }) {
                                MetricCard(title: "SFS Orders", value: viewModel.sfsOrdersCount, subtitle: "Fulfillment Hub", icon: "shippingbox")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            CustomOutlineButton(title: "Serialization", icon: AnyView(Image(systemName: "doc.badge.gearshape")), action: {
                                router.push(ICRoute.serialCertificate)
                            })
                            
                            CustomOutlineButton(title: "Endless Aisle", icon: AnyView(Image(systemName: "square.grid.3x3.fill")), action: {
                                router.push(ICRoute.endlessAisleSelection)
                            })
                        }
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
        .onAppear {
            viewModel.fetchInventoryStats()
            viewModel.fetchSFSCount()
        }
    }
}
