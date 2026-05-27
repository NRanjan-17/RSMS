//
//  ProductDetailView.swift
//  luxury
//
//  Created by Gemini CLI on 21/05/26.
//

import SwiftUI

struct CatalogDetailView: View {
    let catalog: CatalogEntity
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @Environment(CatalogsViewModel.self) private var viewModel
    
    @State private var showingDeleteConfirm = false
    @State private var showingBatchScanner = false
    @State private var scannedSerials: [String] = []
    @State private var showingAllSerialsSheet = false
    
    @State private var showingBulkGenerateAlert = false
    @State private var bulkQuantity: String = ""
    
    private var currentCatalog: CatalogEntity {
        viewModel.catalogs.first(where: { $0.id == catalog.id }) ?? catalog
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentCatalog.name)
                        .font(AppFonts.serif(size: 24, weight: .bold))
                        .foregroundStyle(AppColors.text)
                    
                    HStack {
                        Text(currentCatalog.brand)
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                            .kerning(1.5)
                        
                        Spacer()
                        
                        Text(currentCatalog.status.rawValue.uppercased())
                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(statusTextColor(for: currentCatalog.status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusBackgroundColor(for: currentCatalog.status))
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Catalog Details") {
                LabeledContent("Catalog ID", value: currentCatalog.catalogId)
                LabeledContent("Category", value: currentCatalog.category.rawValue)
                LabeledContent("Description", value: currentCatalog.description)
                LabeledContent("Stock", value: "\((currentCatalog.productIds?.count ?? 0) - (currentCatalog.reserved?.count ?? 0))")
                LabeledContent("Amount", value: CurrencyManager.shared.format(amount: currentCatalog.amount))
                LabeledContent("Barcode", value: currentCatalog.barCode)
            }
            
            if let images = currentCatalog.productImages, !images.isEmpty {
                Section("Product Images") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(images.enumerated()), id: \.offset) { _, url in
                                AsyncImage(url: URL(string: url)) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(AppColors.surface)
                                            .frame(width: 100, height: 100)
                                            .overlay(ProgressView())
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
            
            
            Section("Inventory / Serial Numbers") {
                Button(action: {
                    scannedSerials.removeAll()
                    showingBatchScanner = true
                }) {
                    HStack {
                        Image(systemName: "plus.viewfinder")
                        Text("Add Product(s) / Scan Serials")
                    }
                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                    .padding(.vertical, 4)
                }
                
                Button(action: {
                    bulkQuantity = ""
                    showingBulkGenerateAlert = true
                }) {
                    HStack {
                        Image(systemName: "number.square.fill")
                        Text("Create Bulk Serial Ids")
                    }
                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                    .padding(.vertical, 4)
                }
                
                if let productIds = currentCatalog.productIds, !productIds.isEmpty {
                    ForEach(productIds.prefix(10), id: \.self) { serial in
                        Text(serial)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                    }
                    .onDelete { indexSet in
                        viewModel.removeSerialNumbers(from: currentCatalog, at: indexSet)
                    }
                    
                    if productIds.count > 10 {
                        Button("See All (\(productIds.count))") {
                            showingAllSerialsSheet = true
                        }
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No physical products added yet.")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                }
            }
            Section("Reservations") {
                if let reserved = currentCatalog.reserved, !reserved.isEmpty {
                    ForEach(Array(reserved.enumerated()), id: \.offset) { _, reservationId in
                        Text(reservationId)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                    }
                } else {
                    Text("No Active Reservations")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                }
            }
            
            Section {
                Button(role: .destructive, action: {
                    showingDeleteConfirm = true
                }) {
                    Text("Delete Catalog")
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Catalog Details")
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
                    router.push(CARoute.catalogForm(editCatalog: currentCatalog))
                }
                .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.gold)
            }
        }
        .alert("Delete Catalog", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteCatalog(currentCatalog) {
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this catalog? This action cannot be undone.")
        }
        .fullScreenCover(isPresented: $showingBatchScanner) {
            BatchScannerSheet(scannedSerials: $scannedSerials, existingSerials: currentCatalog.productIds ?? []) {
                if !scannedSerials.isEmpty {
                    viewModel.addSerialNumbers(to: currentCatalog, serials: scannedSerials) {
                        showingBatchScanner = false
                    }
                } else {
                    showingBatchScanner = false
                }
            }
        }
        .alert("Create Bulk Serial IDs", isPresented: $showingBulkGenerateAlert) {
            TextField("Quantity", text: $bulkQuantity)
                .keyboardType(.numberPad)
            
            Button("Cancel", role: .cancel) { }
            
            Button("Generate") {
                if let quantity = Int(bulkQuantity), quantity > 0 {
                    generateBulkSerials(quantity: quantity)
                }
            }
        } message: {
            Text("Enter the number of random serials to generate for this catalog.")
        }
        .sheet(isPresented: $showingAllSerialsSheet) {
            NavigationStack {
                List {
                    if let productIds = currentCatalog.productIds {
                        ForEach(productIds, id: \.self) { serial in
                            Text(serial)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                        }
                        .onDelete { indexSet in
                            viewModel.removeSerialNumbers(from: currentCatalog, at: indexSet)
                        }
                    }
                }
                .navigationTitle("All Serial Numbers")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingAllSerialsSheet = false
                        }
                        .foregroundStyle(AppColors.gold)
                    }
                }
            }
        }
    }
    
    private func generateBulkSerials(quantity: Int) {
        let rawPrefix = currentCatalog.catalogId
        var prefix = String(rawPrefix.prefix(4)).uppercased()
        
        while prefix.count < 4 {
            prefix.append("0")
        }
        
        let existingSerials = Set(currentCatalog.productIds ?? [])
        var newSerials: [String] = []
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        while newSerials.count < quantity {
            let random16 = String((0..<16).map { _ in characters.randomElement()! })
            let generatedSerial = "\(prefix)\(random16)"
            
            if !existingSerials.contains(generatedSerial) && !newSerials.contains(generatedSerial) {
                newSerials.append(generatedSerial)
            }
        }
        
        viewModel.addSerialNumbers(to: currentCatalog, serials: newSerials) {
            // Success
        }
    }
    
    private func statusTextColor(for status: CatalogStatus) -> Color {
        switch status {
        case .active: return AppColors.success
        case .paused: return AppColors.gold
        case .archived: return AppColors.error
        }
    }
    
    private func statusBackgroundColor(for status: CatalogStatus) -> Color {
        statusTextColor(for: status).opacity(0.1)
    }
}



 
