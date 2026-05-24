//
//  BatchScannerSheet.swift
//  luxury
//

import SwiftUI

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
            ScannedSerialsListView(scannedSerials: $scannedSerials, onManualEntry: handleScannedCode)
                .presentationDetents([.fraction(0.2), .medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .large))
                .presentationBackground(.ultraThinMaterial)
                .interactiveDismissDisabled()
        }
        .onAppear {
            scannerService.onScannedCode = handleScannedCode
        }
    }
    
    private func handleScannedCode(_ code: String) {
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
                showToast("Already in System: \(trimmed)")
            } else {
                showToast("Duplicate: \(trimmed)")
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
    let onManualEntry: (String) -> Void
    
    @State private var manualEntry: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Manual Entry")) {
                    HStack {
                        TextField("Type barcode or serial...", text: $manualEntry)
                            .font(AppFonts.sansSerif(size: 16))
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)
                            .submitLabel(.done)
                            .onSubmit {
                                submitManualEntry()
                            }
                        
                        Button(action: submitManualEntry) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(manualEntry.isEmpty ? AppColors.tertiary : AppColors.gold)
                        }
                        .disabled(manualEntry.isEmpty)
                        .buttonStyle(.plain)
                    }
                }
                
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
    
    private func submitManualEntry() {
        let code = manualEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty {
            onManualEntry(code)
            manualEntry = ""
        }
    }
}
