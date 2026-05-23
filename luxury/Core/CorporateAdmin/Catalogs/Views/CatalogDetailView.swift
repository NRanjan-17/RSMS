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
                LabeledContent("Amount", value: String(format: "$%.2f", currentCatalog.amount))
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
                }
                
                if let productIds = currentCatalog.productIds, !productIds.isEmpty {
                    ForEach(productIds, id: \.self) { serial in
                        Text(serial)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                    }
                    .onDelete { indexSet in
                        viewModel.removeSerialNumbers(from: currentCatalog, at: indexSet)
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

struct BatchScannerSheet: View {
    @Binding var scannedSerials: [String]
    let existingSerials: [String]
    let onDone: () -> Void
    
    @State private var scannerService = ScannerService()
    @State private var duplicateToast: String?
    @State private var showingList = true
    
    var body: some View {
        ZStack(alignment: .top) {
            // Full Screen Camera
            QRScannerView(scannerService: scannerService)
                .ignoresSafeArea()
            
            // Custom Top Navigation Bar
            HStack {
                Button("Cancel") { onDone() }
                    .font(AppFonts.sansSerif(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                
                Spacer()
                
                Text("Batch Scan")
                    .font(AppFonts.sansSerif(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button("Done") { onDone() }
                    .font(AppFonts.sansSerif(size: 16, weight: .bold))
                    .foregroundStyle(AppColors.gold)
            }
            .padding()
            .background(Color.black.opacity(0.6))
            
            // Toast Notification
            VStack {
                Spacer()
                if let toast = duplicateToast {
                    Text(toast)
                        .font(AppFonts.sansSerif(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding()
                        .background(AppColors.error)
                        .clipShape(Capsule())
                        .padding(.bottom, 120)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showingList) {
            ScannedSerialsListView(scannedSerials: $scannedSerials)
                .presentationDetents([.fraction(0.2), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .presentationBackground(.ultraThinMaterial)
                .interactiveDismissDisabled()
        }
        .onAppear {
            scannerService.onScannedCode = { code in
                let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                
                if !scannedSerials.contains(trimmed) && !existingSerials.contains(trimmed) {
                    withAnimation {
                        scannedSerials.append(trimmed)
                    }
                    scannerService.playSuccessFeedback()
                } else {
                    scannerService.playErrorFeedback()
                    if existingSerials.contains(trimmed) {
                        showToast("Already in Catalog: \(trimmed)")
                    } else {
                        showToast("Duplicate: \(trimmed)")
                    }
                }
            }
        }
    }
    
    private func showToast(_ message: String) {
        withAnimation {
            duplicateToast = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                if duplicateToast == message {
                    duplicateToast = nil
                }
            }
        }
    }
}

struct ScannedSerialsListView: View {
    @Binding var scannedSerials: [String]
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Scanned Serials (\(scannedSerials.count))")) {
                    if scannedSerials.isEmpty {
                        Text("Scan items to add them here.")
                            .foregroundStyle(AppColors.secondary)
                    } else {
                        ForEach(Array(scannedSerials.reversed().enumerated()), id: \.offset) { _, serial in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppColors.success)
                                Text(serial)
                                    .foregroundStyle(AppColors.text)
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        scannedSerials.removeAll { $0 == serial }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(AppColors.error)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .onDelete { indexSet in
                            let realIndices = indexSet.map { scannedSerials.count - 1 - $0 }
                            for index in realIndices.sorted(by: >) {
                                scannedSerials.remove(at: index)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Scanned Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}



 
