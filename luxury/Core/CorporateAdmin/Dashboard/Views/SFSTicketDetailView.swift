//
//  SFSTicketDetailView.swift
//  luxury
//
//  Created by AutoAgent on 03/06/26.
//

import SwiftUI

struct SFSTicketDetailView: View {
    let ticket: PurchasedItemEntity
    @Environment(Router.self) private var router
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 8) {
                            Text("SFS Ticket Details")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                            
                            let displayStatus = ticket.status.lowercased() == "ready to pick" ? "Ready" : ticket.status.capitalized
                            let statusType: BadgeStatus = ticket.status.lowercased() == "ready to pick" ? .success :
                                                          ticket.status.lowercased() == "secured" ? .neutral : .warning
                            
                            StatusBadge(text: displayStatus, status: statusType)
                                .padding(.top, 4)
                        }
                        .padding(.vertical, 32)
                        
                        Divider().background(AppColors.gold15)
                        
                        VStack(spacing: 16) {
                            DetailRow(label: "Order ID", value: ticket.id.uuidString.uppercased())
                            DetailRow(label: "Transaction ID", value: ticket.transactionId)
                            DetailRow(label: "Product ID", value: ticket.productId.uuidString.uppercased())
                            
                            if let name = ticket.productName {
                                DetailRow(label: "Product Name", value: name)
                            }
                            
                            if let brand = ticket.productBrand {
                                DetailRow(label: "Brand", value: brand)
                            }
                            
                            if let sku = ticket.productSku {
                                DetailRow(label: "SKU", value: sku)
                            }
                            
                            DetailRow(label: "Date Reserved", value: ticket.reservedDate.formatted(date: .abbreviated, time: .shortened))
                            
                            if let delivery = ticket.deliveryDate {
                                DetailRow(label: "Delivery Date", value: delivery.formatted(date: .abbreviated, time: .shortened))
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .navigationTitle("Ticket Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(AppColors.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
