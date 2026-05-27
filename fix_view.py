import re

with open("luxury/Core/InventoryController/Audit/Views/ActiveAuditView.swift", "r") as f:
    content = f.read()

# I will replace the markers carefully.

# First marker: properties
replacement1 = """    let audit: RSMSCycleCount
    @Environment(Router.self) private var router
    @State private var viewModel: ActiveAuditViewModel
    @Environment(\\.dismiss) private var dismiss
    
    @State private var showingBatchScanner = false
    @State private var tempScannedSerials: [String] = []
    
    init(audit: RSMSCycleCount) {
        self.audit = audit
        self._viewModel = State(initialValue: ActiveAuditViewModel(audit: audit))
    }"""
content = re.sub(r'<<<<<<< HEAD\n    let audit: RSMSCycleCount.*?\n=======\n.*?>>>>>>> origin/@inventoryDuplicateMissingScan', replacement1, content, flags=re.DOTALL)

# Second marker: title
replacement2 = """                    Text(audit.title)"""
content = re.sub(r'<<<<<<< HEAD\n                    \n                    Text\(audit\.title\)\n=======\n\n                    Text\("Monthly Full Audit"\)\n>>>>>>> origin/@inventoryDuplicateMissingScan', replacement2, content)

# Third marker: progress bar
replacement3 = """                        if viewModel.totalExpected > 0 {
                            Capsule().fill(AppColors.gold)
                                .frame(width: min(300, 300 * viewModel.progress), height: 4)
                                .animation(.spring(), value: viewModel.progress)
                        }"""
content = re.sub(r'<<<<<<< HEAD\n                        if viewModel\.totalExpected > 0 {\n                            Capsule\(\)\.fill\(AppColors\.gold\)\.frame\(width: min\(300, 300 \* viewModel\.progress\), height: 4\)\n                        }\n=======\n                        Capsule\(\)\.fill\(AppColors\.gold\)\n                            \.frame\(width: 325 \* viewModel\.progress, height: 4\)\n                            \.animation\(\.spring\(\), value: viewModel\.progress\)\n>>>>>>> origin/@inventoryDuplicateMissingScan', replacement3, content)

# Fourth marker: scanned items
replacement4 = """                            .padding(.horizontal, 24)
                        
                        if viewModel.scannedItems.isEmpty {
                            Text("No items scanned yet")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        } else {
                            VStack(spacing: 1) {
                                ForEach(viewModel.scannedItems) { item in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                                .foregroundStyle(item.ok ? .white : AppColors.error)
                                            Text(item.ok ? "MATCHED" : "UNEXPECTED SKU")
                                                .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                        }
                                        Spacer()
                                        Image(systemName: item.ok ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                            .foregroundStyle(item.ok ? AppColors.success : AppColors.error)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(AppColors.surface)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 24)
                        }"""
content = re.sub(r'<<<<<<< HEAD\n                            \.padding\(\.horizontal, 24\).*?\n=======\n\n                        VStack\(spacing: 1\) {.*?>>>>>>> origin/@inventoryDuplicateMissingScan', replacement4, content, flags=re.DOTALL)

# Fifth marker: recount + batch scan button
replacement5 = """                    CustomOutlineButton(title: "Scan Items", icon: AnyView(Image(systemName: "barcode.viewfinder")), action: {
                        tempScannedSerials = viewModel.scannedItems.map { $0.name }
                        showingBatchScanner = true
                    })
                    CustomOutlineButton(title: "Recount", icon: AnyView(Image(systemName: "arrow.clockwise")), action: {
                        Task {
                            await viewModel.loadExpectedItems()
                            viewModel.saveSessionState()
                        }
                    })"""
content = re.sub(r'<<<<<<< HEAD\n                    CustomOutlineButton\(title: "Recount".*?\n=======\n                    CustomOutlineButton\(title: "Scan Items".*?\n>>>>>>> origin/@inventoryDuplicateMissingScan', replacement5, content, flags=re.DOTALL)

# Sixth marker: .task vs .fullScreenCover
replacement6 = """        .task {
            await viewModel.startSession()
        }
        .fullScreenCover(isPresented: $showingBatchScanner) {
            BatchScannerSheet(
                scannedSerials: $tempScannedSerials,
                existingSerials: [],
                allowsDamageReporting: false,
                productName: "Inventory Count",
                expectedSerials: viewModel.expectedItems.map { $0.barcode }
            ) {
                showingBatchScanner = false
                viewModel.addScannedItems(barcodes: tempScannedSerials)
            }
        }"""
content = re.sub(r'<<<<<<< HEAD\n        \.task {\n            await viewModel\.startSession\(\)\n=======\n        \.fullScreenCover\(isPresented: \$showingBatchScanner\) {.*?\n>>>>>>> origin/@inventoryDuplicateMissingScan', replacement6, content, flags=re.DOTALL)

with open("luxury/Core/InventoryController/Audit/Views/ActiveAuditView.swift", "w") as f:
    f.write(content)
