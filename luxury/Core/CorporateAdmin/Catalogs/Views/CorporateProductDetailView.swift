//
//  ProductDetailView.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import SwiftUI

struct CorporateProductDetailView: View {
    let product: ProductEntity
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(CatalogsViewModel.self) private var viewModel
    
    @State private var showingDeleteConfirm = false
    
    private var currentProduct: ProductEntity {
        viewModel.products.first(where: { $0.id == product.id }) ?? product
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentProduct.name)
                        .font(AppFonts.serif(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.text)
                    
                    HStack {
                        Text(currentProduct.brand)
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                            .kerning(1.5)
                        
                        Spacer()
                        
                        Text(currentProduct.status.rawValue.uppercased())
                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(statusTextColor(for: currentProduct.status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusBackgroundColor(for: currentProduct.status))
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Product Details") {
                LabeledContent("Product ID", value: currentProduct.productId)
                LabeledContent("Category", value: currentProduct.category.rawValue)
                LabeledContent("Description", value: currentProduct.description)
                LabeledContent("Stock", value: "\(currentProduct.availableStock)")
                LabeledContent("Amount", value: String(format: "$%.2f", currentProduct.amount))
                LabeledContent("Barcode", value: currentProduct.barCode)
            }
            
            Section("Reservations") {
                if currentProduct.reserved.isEmpty {
                    Text("No Active Reservations")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                } else {
                    ForEach(currentProduct.reserved, id: \.uid) { reservation in
                        ReservationListRow(reservation: reservation)
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    showingDeleteConfirm = true
                }) {
                    Text("Delete Product")
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Product Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    router.push(CARoute.productForm(editProduct: currentProduct))
                }
                .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.gold)
            }
        }
        .alert("Delete Product", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteProduct(currentProduct) {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this product? This action cannot be undone.")
        }
    }
    
    private func statusTextColor(for status: ProductStatus) -> Color {
        switch status {
        case .active: return AppColors.success
        case .paused: return AppColors.gold
        case .archived: return AppColors.error
        }
    }
    
    private func statusBackgroundColor(for status: ProductStatus) -> Color {
        statusTextColor(for: status).opacity(0.1)
    }
}

private struct ReservationListRow: View {
    let reservation: ReservedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(reservation.uid.uuidString)
                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                
                Spacer()
                
                Text(reservation.status.rawValue)
                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("RESERVED")
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(formatDate(reservation.reservedDate))
                        .font(AppFonts.sansSerif(size: 13))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("DELIVERY")
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(reservation.deliveryDate.map { formatDate($0) } ?? "Pending")
                        .font(AppFonts.sansSerif(size: 13))
                }
            }
            
            if !reservation.transactionId.isEmpty {
                Text("TX ID: \(reservation.transactionId)")
                    .font(AppFonts.sansSerif(size: 11))
                    .foregroundStyle(AppColors.gold)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch reservation.status {
        case .pending: return Color.orange
        case .confirmed: return AppColors.gold
        case .cancelled: return Color.red
        case .delivered: return Color.green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .none
        return displayFormatter.string(from: date)
    }
}

 
