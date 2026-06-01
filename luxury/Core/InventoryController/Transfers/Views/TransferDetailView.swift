//
//  TransferDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//  Modified by Antigravity on 01/06/26.
//

import SwiftUI
import Supabase

struct TransferDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var transfer: TransferRequest
    @State private var isLoading = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    init(transfer: TransferRequest) {
        _transfer = State(initialValue: transfer)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Back Button
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Transfer Detail")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider().background(AppColors.border)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(transfer.reference)
                                    .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(1.5)
                                Spacer()
                                StatusBadge(text: transfer.status, status: transfer.badgeStatus)
                            }
                            
                            Text("Inter-store Movement")
                                .font(AppFonts.serif(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.tertiary).frame(width: 8, height: 8)
                                Text("FROM: \(transfer.source)")
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(AppColors.text)
                            }
                            Rectangle().fill(AppColors.gold15).frame(width: 1, height: 20).padding(.leading, 3.5)
                            HStack(spacing: 12) {
                                Circle().fill(AppColors.gold).frame(width: 8, height: 8)
                                Text("TO: \(transfer.destination)")
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(AppColors.text)
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ITEMS (\(transfer.itemCount))")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 1) {
                                ForEach(transfer.items) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text(item.sku)
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        Spacer()
                                        Text("×\(item.qty)")
                                            .font(AppFonts.serif(size: 18, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(AppColors.surface)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 40)
                }
                
                // Action Buttons at the bottom
                if isLoading {
                    ProgressView()
                        .tint(AppColors.gold)
                        .padding(.vertical, 20)
                } else {
                    let status = transfer.status.lowercased()
                    if status == "approved" {
                        VStack {
                            CustomButton(title: "Ship Transfer", action: {
                                shipTransfer()
                            })
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    } else if status == "in transit" {
                        VStack {
                            CustomButton(title: "Complete Transfer (Receive)", action: {
                                completeTransfer()
                            })
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .navigationTitle("Transfer Request")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert(
            "Transfer Error",
            isPresented: $showAlert
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private func shipTransfer() {
        var allTransfers = TransferPersistence.shared.loadTransfers()
        if let index = allTransfers.firstIndex(where: { $0.id == transfer.id }) {
            let updated = TransferRequest(
                id: transfer.id,
                reference: transfer.reference,
                source: transfer.source,
                destination: transfer.destination,
                items: transfer.items,
                status: "In Transit",
                badgeStatus: .pending
            )
            allTransfers[index] = updated
            TransferPersistence.shared.saveAll(allTransfers)
            self.transfer = updated
            
            SystemLogService.shared.logAction(
                category: .inventory,
                severity: .info,
                message: "Stock Transfer \(transfer.reference) marked as In Transit.",
                boutiqueName: transfer.source
            )
            
            NotificationCenter.default.post(
                name: NSNotification.Name("StockTransferUpdated"),
                object: nil
            )
        }
    }
    
    private func completeTransfer() {
        isLoading = true
        Task {
            do {
                let boutiques: [CorporateBoutique] = try await SupabaseManager.shared.client
                    .from("boutiques")
                    .select()
                    .execute()
                    .value
                
                let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .execute()
                    .value
                
                guard let destBoutique = boutiques.first(where: {
                    $0.name.localizedCaseInsensitiveCompare(transfer.destination) == .orderedSame
                }) else {
                    throw NSError(domain: "Transfer", code: 10, userInfo: [NSLocalizedDescriptionKey: "Destination store '\(transfer.destination)' not found in database."])
                }
                
                for item in transfer.items {
                    guard let catalogItem = catalogs.first(where: {
                        $0.barCode.lowercased() == item.sku.lowercased() ||
                        $0.catalogId.lowercased() == item.sku.lowercased()
                    }) else {
                        throw NSError(domain: "Transfer", code: 11, userInfo: [NSLocalizedDescriptionKey: "Product with SKU '\(item.sku)' not found in catalogs."])
                    }
                    
                    let inventoryList: [InventoryItem] = try await SupabaseManager.shared.client
                        .from("inventory")
                        .select()
                        .eq("sku_id", value: catalogItem.id.uuidString)
                        .eq("store_id", value: destBoutique.id.uuidString)
                        .execute()
                        .value
                    
                    if let firstInventory = inventoryList.first {
                        let newQty = firstInventory.quantity + item.qty
                        _ = try await SupabaseManager.shared.client
                            .from("inventory")
                            .update(["quantity": newQty])
                            .eq("id", value: firstInventory.id.uuidString)
                            .execute()
                    } else {
                        let newInventoryItem = InventoryItem(
                            id: UUID(),
                            storeId: destBoutique.id,
                            skuId: catalogItem.id,
                            quantity: item.qty,
                            productAvailable: true
                        )
                        _ = try await SupabaseManager.shared.client
                            .from("inventory")
                            .insert(newInventoryItem)
                            .execute()
                    }
                }
                
                var allTransfers = TransferPersistence.shared.loadTransfers()
                if let index = allTransfers.firstIndex(where: { $0.id == transfer.id }) {
                    let updated = TransferRequest(
                        id: transfer.id,
                        reference: transfer.reference,
                        source: transfer.source,
                        destination: transfer.destination,
                        items: transfer.items,
                        status: "Completed",
                        badgeStatus: .success
                    )
                    allTransfers[index] = updated
                    TransferPersistence.shared.saveAll(allTransfers)
                    
                    await MainActor.run {
                        self.transfer = updated
                    }
                    
                    SystemLogService.shared.logAction(
                        category: .inventory,
                        severity: .info,
                        message: "Stock Transfer \(transfer.reference) completed/received at \(transfer.destination).",
                        boutiqueName: transfer.destination
                    )
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name("StockTransferUpdated"),
                        object: nil
                    )
                }
                
                await MainActor.run {
                    self.isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                    self.isLoading = false
                }
            }
        }
    }
}
