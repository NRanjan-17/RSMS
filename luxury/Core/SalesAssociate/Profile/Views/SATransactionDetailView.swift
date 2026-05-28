//
//  SATransactionDetailView.swift
//  luxury
//
//  Created by Antigravity on 27/05/26.
//

import SwiftUI
import Supabase

struct SATransactionDetailView: View {
    let transaction: SATransactionEntity
    @Environment(Router.self) private var router
    @Environment(\.openURL) private var openURL
    @State private var isEmailing = false
    @State private var emailSent = false
    @State private var purchasedProducts: [(qty: Int, product: CatalogEntity)] = []
    @State private var isLoadingProducts = true
    
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
                            
                            Text(CurrencyManager.shared.format(amount: transaction.transactionAmount))
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
                            
                            if isLoadingProducts {
                                ProgressView()
                                    .padding(.top, 8)
                            } else if !purchasedProducts.isEmpty {
                                Divider().background(AppColors.gold15)
                                    .padding(.vertical, 8)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Products")
                                        .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                    
                                    ForEach(purchasedProducts, id: \.product.id) { item in
                                        HStack(alignment: .top) {
                                            Text("\(item.qty)x")
                                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                                .foregroundStyle(AppColors.secondary)
                                                
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.product.name)
                                                    .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                Text("S/N: \(item.product.barCode)")
                                                    .font(AppFonts.sansSerif(size: 11))
                                                    .foregroundStyle(AppColors.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Text(CurrencyManager.shared.format(amount: item.product.amount * Double(item.qty)))
                                                .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
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
        .task {
            await fetchProducts()
        }
    }
    
    private func fetchProducts() async {
        do {
            let dbItems: [PurchasedItem] = try await SupabaseManager.shared.client
                .from("purchased_items")
                .select()
                .eq("transaction_id", value: transaction.id.uuidString)
                .execute()
                .value
            
            if !dbItems.isEmpty {
                let productIds = dbItems.map { $0.productId }
                let dbCatalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .in("id", values: productIds.map { $0.uuidString })
                    .execute()
                    .value
                
                // Group by product
                var grouped: [UUID: Int] = [:]
                for item in dbItems {
                    grouped[item.productId, default: 0] += 1
                }
                
                let finalProducts = grouped.compactMap { dict in
                    if let catalog = dbCatalogs.first(where: { $0.id == dict.key }) {
                        return (qty: dict.value, product: catalog)
                    }
                    return nil
                }
                
                await MainActor.run {
                    self.purchasedProducts = finalProducts
                    self.isLoadingProducts = false
                }
            } else {
                await MainActor.run {
                    self.isLoadingProducts = false
                }
            }
        } catch {
            print("Error fetching products for transaction: \(error)")
            await MainActor.run {
                self.isLoadingProducts = false
            }
        }
    }
    
    private func sendEmailReceipt() {
        guard !isEmailing else { return }
        guard let email = transaction.client?.email else { return }
        
        let subject = "Your RSMS Receipt"
        var bodyStr = "Thank you for your purchase.\n\n"
        bodyStr += "Transaction ID: \(transaction.id.uuidString.prefix(8).uppercased())\n"
        bodyStr += "Total Paid: \(CurrencyManager.shared.format(amount: transaction.transactionAmount))\n\n"
        
        if !purchasedProducts.isEmpty {
            bodyStr += "Products:\n"
            for item in purchasedProducts {
                bodyStr += "\(item.qty)x \(item.product.name) (S/N: \(item.product.barCode)) - \(CurrencyManager.shared.format(amount: item.product.amount * Double(item.qty)))\n"
            }
            bodyStr += "\n"
        }
        
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let bodyEncoded = bodyStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(subjectEncoded)&body=\(bodyEncoded)") {
            openURL(url)
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
