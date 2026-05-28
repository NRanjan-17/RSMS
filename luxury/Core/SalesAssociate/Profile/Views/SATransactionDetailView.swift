//
//  SATransactionDetailView.swift
//  luxury
//
//  Created by Antigravity on 27/05/26.
//

import SwiftUI

struct SATransactionDetailView: View {
    let transaction: SATransactionEntity
    @Environment(Router.self) private var router
    @State private var isEmailing = false
    @State private var emailSent = false
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Button(action: { router.pop() }) {
                            Image(systemName: "chevron.left")
                                .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        
                        Spacer()
                        
                        Text("Transaction Details")
                            .font(AppFonts.serif(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        // Placeholder for symmetry
                        Image(systemName: "chevron.left").opacity(0)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    // Main Receipt Card
                    VStack(spacing: 0) {
                        // Top Section
                        VStack(spacing: 12) {
                            Text("Total Paid")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                            
                            Text("$\(String(format: "%.2f", transaction.transactionAmount))")
                                .font(AppFonts.serif(size: 40, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                            
                            if let date = transaction.dateOfTransaction {
                                Text(formatDate(date))
                                    .font(AppFonts.sansSerif(size: 13))
                                    .foregroundStyle(AppColors.secondary)
                            }
                        }
                        .padding(.vertical, 32)
                        
                        Divider().background(AppColors.gold15)
                        
                        // Details Section
                        VStack(spacing: 16) {
                            DetailRow(label: "Transaction ID", value: transaction.id.uuidString.prefix(8).uppercased())
                            
                            if let client = transaction.client {
                                DetailRow(label: "Client", value: client.name)
                                DetailRow(label: "Client Email", value: client.email)
                            } else {
                                DetailRow(label: "Client", value: "Guest Checkout")
                            }
                            
                            DetailRow(label: "Purpose", value: transaction.purpose)
                        }
                        .padding(24)
                    }
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                    .padding(.horizontal, 24)
                    
                    // Actions
                    VStack(spacing: 16) {
                        Button(action: sendEmailReceipt) {
                            HStack {
                                if isEmailing {
                                    ProgressView().tint(.white)
                                } else if emailSent {
                                    Image(systemName: "checkmark")
                                    Text("Receipt Emailed")
                                } else {
                                    Image(systemName: "envelope")
                                    Text("Email Receipt to Client")
                                }
                            }
                            .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                            .foregroundStyle(emailSent ? AppColors.background : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(emailSent ? AppColors.gold : AppColors.surface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(emailSent ? Color.clear : AppColors.gold, lineWidth: 1))
                        }
                        .disabled(isEmailing || emailSent || transaction.client?.email == nil)
                        
                        if transaction.client?.email == nil {
                            Text("No email address associated with this client.")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.error)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func sendEmailReceipt() {
        guard !isEmailing else { return }
        isEmailing = true
        
        // Simulate API call for sending email
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isEmailing = false
            emailSent = true
        }
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
