//
//  VarianceReportView.swift
//  luxury
//
//  Created by Antigravity on 27/05/26.
//

import SwiftUI

struct VarianceReportView: View {
    @Environment(\.dismiss) private var dismiss
    let audit: RSMSCycleCount
    
    private var report: VarianceReport {
        if let session = AuditPersistence.shared.loadSession(id: audit.id), let rep = session.varianceReport {
            return rep
        }
        return VarianceReport(
            id: audit.id,
            boutiqueName: "Main Boutique",
            date: Date(),
            controllerName: "Alex Mercer",
            items: [
                VarianceReportItem(id: UUID(), productName: "Rolex Submariner Date", sku: "RX-126610", expectedQty: 5, countedQty: 4, variance: -1, isArchivedProduct: false),
                VarianceReportItem(id: UUID(), productName: "Omega Seamaster 300M", sku: "OM-21030", expectedQty: 8, countedQty: 8, variance: 0, isArchivedProduct: false),
                VarianceReportItem(id: UUID(), productName: "Audemars Piguet Royal Oak", sku: "AP-15500", expectedQty: 2, countedQty: 3, variance: 1, isArchivedProduct: false),
                VarianceReportItem(id: UUID(), productName: "Patek Philippe Aquanaut", sku: "PP-5167", expectedQty: 1, countedQty: 0, variance: -1, isArchivedProduct: true)
            ]
        )
    }
    
    @State private var filterOver = true
    @State private var filterUnder = true
    @State private var filterZero = false
    
    @State private var discrepantExpanded = true
    @State private var matchedExpanded = false
    
    @State private var shareURL: URL?
    @State private var showShareSheet = false
    
    private var filteredItems: [VarianceReportItem] {
        report.items.filter { item in
            if item.variance > 0 {
                return filterOver
            } else if item.variance < 0 {
                return filterUnder
            } else {
                return filterZero
            }
        }.sorted { abs($0.variance) > abs($1.variance) }
    }
    
    private var discrepantItems: [VarianceReportItem] {
        filteredItems.filter { $0.variance != 0 }
    }
    
    private var matchedItems: [VarianceReportItem] {
        filteredItems.filter { $0.variance == 0 }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(report.boutiqueName.uppercased())
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(1.5)
                            
                            Text("Inventory Count Result")
                                .font(AppFonts.serif(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Text("Counted by \(report.controllerName) on \(report.date.formatted())")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                        }
                        .padding(.horizontal, 24)
                        
                        HStack(spacing: 8) {
                            FilterBadge(title: "Over-stock", active: $filterOver)
                            FilterBadge(title: "Under-stock", active: $filterUnder)
                            FilterBadge(title: "Matched", active: $filterZero)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 20) {
                            DisclosureGroup(isExpanded: $discrepantExpanded) {
                                VStack(spacing: 12) {
                                    if discrepantItems.isEmpty {
                                        Text("All items matched — no variance found.")
                                            .font(AppFonts.sansSerif(size: 14))
                                            .foregroundStyle(AppColors.secondary)
                                            .padding(.vertical, 20)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        ForEach(discrepantItems) { item in
                                            ReportRow(item: item)
                                        }
                                    }
                                }
                                .padding(.top, 12)
                            } label: {
                                HStack {
                                    Text("DISCREPANT ITEMS")
                                        .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    StatusBadge(text: "\(discrepantItems.count) Items", status: .warning)
                                }
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            
                            DisclosureGroup(isExpanded: $matchedExpanded) {
                                VStack(spacing: 12) {
                                    if matchedItems.isEmpty {
                                        Text("No matched items found in active view.")
                                            .font(AppFonts.sansSerif(size: 14))
                                            .foregroundStyle(AppColors.secondary)
                                            .padding(.vertical, 20)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        ForEach(matchedItems) { item in
                                            ReportRow(item: item)
                                        }
                                    }
                                }
                                .padding(.top, 12)
                            } label: {
                                HStack {
                                    Text("MATCHED ITEMS")
                                        .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    StatusBadge(text: "\(matchedItems.count) Items", status: .neutral)
                                }
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 20)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        if let url = generateCSV() {
                            shareURL = url
                            showShareSheet = true
                        }
                    }) {
                        Label("Export CSV", systemImage: "doc.text.fill")
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        if let url = generatePDF() {
                            shareURL = url
                            showShareSheet = true
                        }
                    }) {
                        Label("Export PDF", systemImage: "doc.richtext.fill")
                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppColors.gold)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Variance Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    private func generateCSV() -> URL? {
        var csvString = "Item Name,SKU,Expected Qty,Counted Qty,Variance\n"
        for item in filteredItems {
            let escapedName = item.productName.replacingOccurrences(of: "\"", with: "\"\"")
            csvString += "\"\(escapedName)\",\(item.sku),\(item.expectedQty),\(item.countedQty),\(item.variance)\n"
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("VarianceReport.csv")
        try? csvString.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
    
    @MainActor
    private func generatePDF() -> URL? {
        let printView = PDFReportView(report: report, filteredItems: filteredItems)
        let renderer = ImageRenderer(content: printView)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("VarianceReport.pdf")
        
        renderer.render { size, context in
            var box = CGRect(origin: .zero, size: size)
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            pdfContext.beginPDFPage(nil)
            context(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        return url
    }
}

private struct FilterBadge: View {
    let title: String
    @Binding var active: Bool
    
    var body: some View {
        Button(action: { active.toggle() }) {
            Text(title)
                .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(active ? AppColors.gold : AppColors.surface)
                .foregroundStyle(active ? AppColors.background : AppColors.secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(active ? .clear : AppColors.gold15, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ReportRow: View {
    let item: VarianceReportItem
    
    private var varianceColor: Color {
        if item.variance > 0 {
            return AppColors.success
        } else if item.variance < 0 {
            return AppColors.error
        } else {
            return AppColors.secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.productName)
                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                        if item.isArchivedProduct {
                            Text("Archived Product")
                                .font(AppFonts.sansSerif(size: 8, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppColors.error.opacity(0.15))
                                .foregroundStyle(AppColors.error)
                                .clipShape(Capsule())
                        }
                    }
                    Text("SKU: \(item.sku)")
                        .font(AppFonts.sansSerif(size: 11))
                        .foregroundStyle(AppColors.secondary)
                }
                Spacer()
                
                Text(item.variance > 0 ? "+\(item.variance)" : "\(item.variance)")
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(varianceColor)
            }
            
            HStack(spacing: 12) {
                Text("Expected: \(item.expectedQty)")
                Text("•")
                Text("Counted: \(item.countedQty)")
            }
            .font(AppFonts.sansSerif(size: 11))
            .foregroundStyle(AppColors.tertiary)
            
            Divider().background(AppColors.border)
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private struct PDFReportView: View {
    let report: VarianceReport
    let filteredItems: [VarianceReportItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("INVENTORY VARIANCE REPORT")
                .font(AppFonts.sansSerif(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Boutique: \(report.boutiqueName)")
                    Text("Date: \(report.date.formatted())")
                    Text("Controller: \(report.controllerName)")
                }
                .font(AppFonts.sansSerif(size: 12))
                .foregroundStyle(AppColors.secondary)
                Spacer()
            }
            
            Divider()
            
            Text("Line Items")
                .font(AppFonts.sansSerif(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Item").font(AppFonts.sansSerif(size: 11, weight: .bold)).frame(maxWidth: .infinity, alignment: .leading)
                    Text("SKU").font(AppFonts.sansSerif(size: 11, weight: .bold)).frame(width: 80, alignment: .leading)
                    Text("Expected").font(AppFonts.sansSerif(size: 11, weight: .bold)).frame(width: 60, alignment: .trailing)
                    Text("Counted").font(AppFonts.sansSerif(size: 11, weight: .bold)).frame(width: 60, alignment: .trailing)
                    Text("Variance").font(AppFonts.sansSerif(size: 11, weight: .bold)).frame(width: 60, alignment: .trailing)
                }
                .foregroundStyle(.black)
                
                Divider()
                
                ForEach(filteredItems) { item in
                    HStack {
                        HStack {
                            Text(item.productName)
                            if item.isArchivedProduct {
                                Text("(Archived)")
                            }
                        }
                        .font(AppFonts.sansSerif(size: 10))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(item.sku).font(AppFonts.sansSerif(size: 10)).frame(width: 80, alignment: .leading)
                        Text("\(item.expectedQty)").font(AppFonts.sansSerif(size: 10)).frame(width: 60, alignment: .trailing)
                        Text("\(item.countedQty)").font(AppFonts.sansSerif(size: 10)).frame(width: 60, alignment: .trailing)
                        Text("\(item.variance > 0 ? "+" : "")\(item.variance)").font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(item.variance > 0 ? AppColors.success : (item.variance < 0 ? AppColors.error : Color.black))
                            .frame(width: 60, alignment: .trailing)
                    }
                    .foregroundStyle(.black)
                }
            }
        }
        .padding(40)
        .frame(width: 595, height: 842)
        .background(Color.white)
    }
}
