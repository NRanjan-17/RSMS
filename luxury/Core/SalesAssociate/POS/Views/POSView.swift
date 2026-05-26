//
//  POSView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct POSView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = POSViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "Cart")
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 7) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(AppColors.gold15)
                                    .frame(width: 22, height: 22)
                                Text("RB")
                                    .font(AppFonts.serif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            Text("Rahul Bajaj")
                                .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                .foregroundStyle(.white)
                            StatusBadge(text: "UHNW", status: .success)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppColors.gold08)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                        
                        if viewModel.offlineCartQueued {
                            HStack(spacing: 10) {
                                Image(systemName: "wifi.slash")
                                    .foregroundStyle(AppColors.gold)
                                Text("Offline cart snapshot saved locally")
                                    .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                    .foregroundStyle(AppColors.gold)
                                Spacer()
                                StatusBadge(text: "Queued", status: .pending)
                            }
                            .padding(14)
                            .background(AppColors.gold08)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                            .padding(.bottom, 14)
                        }
                        
                        VStack(spacing: 10) {
                            ForEach(viewModel.cartItems) { item in
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppColors.surface2)
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "circle.grid.cross")
                                            .font(.system(size: 20))
                                            .foregroundStyle(AppColors.gold)
                                            .opacity(0.3)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.brand.uppercased())
                                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                            .kerning(1)
                                        Text(item.name)
                                            .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text(viewModel.formatCurrency(item.price))
                                            .font(AppFonts.serif(size: 15, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        Circle()
                                            .stroke(AppColors.gold15, lineWidth: 0.5)
                                            .background(AppColors.surface2)
                                            .frame(width: 26, height: 26)
                                            .overlay(Text("−").font(.system(size: 14)).foregroundStyle(AppColors.secondary))
                                        
                                        Text("\(item.qty)")
                                            .font(AppFonts.serif(size: 16, weight: .medium))
                                            .foregroundStyle(.white)
                                        
                                        Circle()
                                            .stroke(AppColors.gold15, lineWidth: 0.5)
                                            .background(AppColors.surface2)
                                            .frame(width: 26, height: 26)
                                            .overlay(Text("+").font(.system(size: 14)).foregroundStyle(AppColors.secondary))
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(AppColors.gold)
                                Text("Discount \(Int(viewModel.discountRate * 100))% by Arjun Singh")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.gold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("−\(viewModel.formatCurrency(viewModel.discount))")
                                    .font(AppFonts.serif(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            
                            HStack(spacing: 8) {
                                Button("8%") { viewModel.applyDiscount(0.08) }
                                Button("12%") { viewModel.applyDiscount(0.12) }
                                Button("Approve") { viewModel.approve() }
                                Button("Reject") { viewModel.reject() }
                            }
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .buttonStyle(.bordered)
                            .tint(AppColors.gold)
                            
                            if viewModel.requiresApproval {
                                HStack(spacing: 8) {
                                    StatusBadge(text: viewModel.approvalState.rawValue, status: viewModel.approvalState == .approved ? .success : viewModel.approvalState == .rejected ? .error : .pending)
                                    Text("Manager approval required above 10%. Immutable audit will capture decision state.")
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.secondary)
                                }
                            }
                            
                            Toggle("Tax-free eligible client", isOn: $viewModel.taxFree)
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.text)
                                .toggleStyle(LuxuryToggleStyle())
                        }
                        .padding(14)
                        .background(AppColors.gold.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold50, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                        
                        VStack(spacing: 10) {
                            PriceRow(label: "Subtotal", value: viewModel.formatCurrency(viewModel.subtotal))
                            PriceRow(label: "Discount (\(Int(viewModel.discountRate * 100))%)", value: "−\(viewModel.formatCurrency(viewModel.discount))")
                            PriceRow(label: viewModel.taxFree ? "GST" : "GST (3%)", value: "+\(viewModel.formatCurrency(viewModel.tax))")
                            
                            Divider().background(AppColors.gold15).padding(.vertical, 4)
                            
                            HStack {
                                Text("Total")
                                    .font(AppFonts.sansSerif(size: 15, weight: .medium))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(viewModel.formatCurrency(viewModel.total))
                                    .font(AppFonts.serif(size: 22, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        CustomOutlineButton(title: "Start Return or Exchange", icon: AnyView(Image(systemName: "arrow.uturn.backward")), action: {
                            router.push(SARoute.returns)
                        })
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        .padding(.bottom, 120)
                    }
                    .padding(.top, 14)
                }
                
                VStack(spacing: 0) {
                    if let error = viewModel.paymentError {
                        Text(error)
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.error)
                            .padding(.bottom, 8)
                    }
                    
                    Button(action: {
                        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootVC = scene.windows.first?.rootViewController else { return }
                        
                        Task {
                            let success = await viewModel.processPayment(presentingViewController: rootVC)
                            if success {
                                router.push(SARoute.payment)
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            if viewModel.isProcessingPayment {
                                ProgressView()
                                    .tint(AppColors.background)
                            } else {
                                Text("Checkout · \(viewModel.formatCurrency(viewModel.total))")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                        }
                        .font(AppFonts.sansSerif(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.gold))
                    }
                    .buttonStyle(.plain)
                    .disabled((viewModel.requiresApproval && viewModel.approvalState != .approved) || viewModel.isProcessingPayment)
                    .opacity((viewModel.requiresApproval && viewModel.approvalState != .approved) || viewModel.isProcessingPayment ? 0.45 : 1)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct PriceRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.sansSerif(size: 13))
                .foregroundStyle(AppColors.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.serif(size: 13))
                .foregroundStyle(.white)
        }
    }
}
