//
//  BatchScannerSheet.swift
//  luxury
//

import SwiftUI

struct BatchScannerSheet: View {
    @Binding var scannedSerials: [String]
    @Binding var damagedItems: [DamagedDeliveryItemDraft]

    let existingSerials: [String]
    let allowsDamageReporting: Bool
    let productName: String
    let onDone: () -> Void

    @State private var scannerService = ScannerService()
    @State private var duplicateToast: String?
    @State private var showingList = true

    init(
        scannedSerials: Binding<[String]>,
        existingSerials: [String],
        allowsDamageReporting: Bool = false,
        damagedItems: Binding<[DamagedDeliveryItemDraft]> = .constant([]),
        productName: String = "",
        onDone: @escaping () -> Void
    ) {
        _scannedSerials = scannedSerials
        _damagedItems = damagedItems
        self.existingSerials = existingSerials
        self.allowsDamageReporting = allowsDamageReporting
        self.productName = productName
        self.onDone = onDone
    }

    var body: some View {
        ZStack(alignment: .top) {
            QRScannerView(scannerService: scannerService)
                .ignoresSafeArea()

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
            ScannedSerialsListView(
                scannedSerials: $scannedSerials,
                damagedItems: $damagedItems,
                allowsDamageReporting: allowsDamageReporting,
                productName: productName,
                onManualEntry: handleScannedCode
            )
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
    @Binding var damagedItems: [DamagedDeliveryItemDraft]

    let allowsDamageReporting: Bool
    let productName: String
    let onManualEntry: (String) -> Void

    @State private var manualEntry = ""
    @State private var reportingSerial: ReportedSerial?

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
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: damageReport(for: serial) == nil ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                        .foregroundStyle(damageReport(for: serial) == nil ? AppColors.success : AppColors.error)
                                    Text(serial)
                                        .foregroundStyle(AppColors.text)

                                    Spacer()

                                    Button(action: {
                                        withAnimation {
                                            scannedSerials.removeAll { $0 == serial }
                                            damagedItems.removeAll { $0.serial == serial }
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundStyle(AppColors.error)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }

                                if let report = damageReport(for: serial) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Damaged on arrival")
                                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                            .foregroundStyle(AppColors.error)
                                        Text(report.description)
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.secondary)
                                            .lineLimit(2)
                                    }
                                }

                                if allowsDamageReporting {
                                    Button(action: {
                                        reportingSerial = ReportedSerial(value: serial)
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: damageReport(for: serial) == nil ? "camera.fill" : "square.and.pencil")
                                            Text(damageReport(for: serial) == nil ? "Mark Damaged" : "Edit Damage Report")
                                        }
                                        .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            let realIndices = indexSet.map { scannedSerials.count - 1 - $0 }
                            for index in realIndices.sorted(by: >) {
                                damagedItems.removeAll { $0.serial == scannedSerials[index] }
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
        .sheet(item: $reportingSerial) { item in
            DamagedItemReportSheet(
                serial: item.value,
                productName: productName,
                existingReport: damageReport(for: item.value)
            ) { report in
                if let index = damagedItems.firstIndex(where: { $0.serial == report.serial }) {
                    damagedItems[index] = report
                } else {
                    damagedItems.append(report)
                }
            }
        }
    }

    private func submitManualEntry() {
        let code = manualEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty {
            onManualEntry(code)
            manualEntry = ""
        }
    }

    private func damageReport(for serial: String) -> DamagedDeliveryItemDraft? {
        damagedItems.first(where: { $0.serial == serial })
    }
}

private struct ReportedSerial: Identifiable {
    let value: String

    var id: String {
        value
    }
}
