//
//  AfterSalesViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import PhotosUI
import Supabase

struct AfterSalesIntakeView: View {
    @Environment(\.dismiss) private var dismiss
    
    let client: Client
    let serialNumber: String?
    let isWarrantyActive: Bool
    let purchaseId: UUID?
    
    @State private var serial: String
    @State private var issue = ""
    @State private var created = false
    @State private var isCreating = false
    @State private var errorMessage: String? = nil
    @State private var showSuccessAlert = false
    
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var showMediaSourceMenu = false
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uploadedImages: [UIImage] = []
    
    @State private var isDropdownOpen = false
    @State private var selectedPurchase: ClientPurchase? = nil
    @State private var clientPurchases: [ClientPurchase] = []
    
    @State private var dynamicIsWarrantyActive: Bool = true
    @State private var dynamicWarrantyText: String? = nil
    
    private var isReadOnly: Bool {
        return serialNumber != nil
    }
    
    init(client: Client, serialNumber: String? = nil, isWarrantyActive: Bool = true, purchaseId: UUID? = nil) {
        self.client = client
        self.serialNumber = serialNumber
        self.isWarrantyActive = isWarrantyActive
        self.purchaseId = purchaseId
        
        let localPurchases = PurchaseHistoryService.shared.fetchPurchases(clientId: client.id)
        self._clientPurchases = State(initialValue: localPurchases)
        
        if let sn = serialNumber {
            self._serial = State(initialValue: sn)
            // Look up corresponding purchase by ID or Serial
            let matchingPurchase = localPurchases.first { p in
                if let pid = purchaseId, p.id == pid { return true }
                let prodId = "PRD-" + String(p.id.uuidString.prefix(8).uppercased())
                return prodId == sn
            }
            if let purchase = matchingPurchase {
                let wInfo = Self.checkWarrantyStatus(purchaseDateStr: purchase.date)
                self._dynamicIsWarrantyActive = State(initialValue: wInfo.isActive)
                self._dynamicWarrantyText = State(initialValue: wInfo.expirationText)
                self._selectedPurchase = State(initialValue: purchase)
            } else {
                let wText = isWarrantyActive ? "Valid until 24 nov 2026" : "Expired on 24 nov 2026"
                self._dynamicIsWarrantyActive = State(initialValue: isWarrantyActive)
                self._dynamicWarrantyText = State(initialValue: wText)
            }
        } else {
            self._serial = State(initialValue: "")
            self._dynamicIsWarrantyActive = State(initialValue: true)
            self._dynamicWarrantyText = State(initialValue: nil)
        }
    }
    
    private static func checkWarrantyStatus(purchaseDateStr: String) -> (isActive: Bool, expirationText: String) {
        let formatters = [
            "MMM yyyy",
            "dd MMM yyyy",
            "yyyy-MM-dd",
            "d MMM yyyy",
            "MMM dd, yyyy"
        ]
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        var parsedDate: Date? = nil
        for format in formatters {
            df.dateFormat = format
            if let parsed = df.date(from: purchaseDateStr) {
                parsedDate = parsed
                break
            }
        }
        
        guard let pDate = parsedDate else {
            return (isActive: true, expirationText: "Valid until 24 nov 2026")
        }
        
        if let futureDate = Calendar.current.date(byAdding: .year, value: 2, to: pDate) {
            let isActive = futureDate > Date()
            df.dateFormat = "d MMM yyyy"
            let dateStr = df.string(from: futureDate).lowercased()
            let text = isActive ? "Valid until \(dateStr)" : "Expired on \(dateStr)"
            return (isActive: isActive, expirationText: text)
        }
        
        return (isActive: true, expirationText: "Valid until 24 nov 2026")
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        StatusBadge(
                            text: created ? "Ticket Created" : (uploadedImages.isEmpty ? "Photo Required" : "Ready to Create"),
                            status: created ? .success : (uploadedImages.isEmpty ? .warning : .pending)
                        )
                        
                        // Client card (read-only)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Client")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            Text("\(client.name) · \(client.tier.rawValue.uppercased()) · Appointment linked")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Serial Number / Selection card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Serial Number")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            
                            if isReadOnly {
                                Text(serial)
                                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                            } else {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isDropdownOpen.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(selectedPurchase?.name ?? "Select Product from History")
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(selectedPurchase == nil ? AppColors.secondary : .white)
                                        Spacer()
                                        Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                                            .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                if isDropdownOpen {
                                    VStack(spacing: 8) {
                                        Divider().background(AppColors.gold.opacity(0.2))
                                        
                                        if clientPurchases.isEmpty {
                                            Text("No purchases found for this client")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                                .padding(.vertical, 8)
                                        } else {
                                            ForEach(clientPurchases) { p in
                                                let prodId = "PRD-" + String(p.id.uuidString.prefix(8).uppercased())
                                                Button(action: {
                                                    selectedPurchase = p
                                                    serial = prodId
                                                    
                                                    let wInfo = Self.checkWarrantyStatus(purchaseDateStr: p.date)
                                                    dynamicIsWarrantyActive = wInfo.isActive
                                                    dynamicWarrantyText = wInfo.expirationText
                                                    
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        isDropdownOpen = false
                                                    }
                                                }) {
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(p.name)
                                                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                                .foregroundStyle(.white)
                                                            Text("SN: \(prodId) · \(p.date)")
                                                                .font(AppFonts.sansSerif(size: 11))
                                                                .foregroundStyle(AppColors.secondary)
                                                        }
                                                        Spacer()
                                                        if selectedPurchase?.id == p.id {
                                                            Image(systemName: "checkmark")
                                                                .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                                                .foregroundStyle(AppColors.gold)
                                                        }
                                                    }
                                                    .padding(.vertical, 6)
                                                    .contentShape(Rectangle())
                                                }
                                                .buttonStyle(.plain)
                                                
                                                if p.id != clientPurchases.last?.id {
                                                    Divider().background(AppColors.gold.opacity(0.1))
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                                
                                if selectedPurchase != nil {
                                    Divider().background(AppColors.gold.opacity(0.2))
                                        .padding(.top, 4)
                                    
                                    HStack {
                                        Text("Serial:")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                        Text(serial)
                                            .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Service Details card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Service Details")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            TextField("Issue and condition notes", text: $issue, axis: .vertical)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .textFieldStyle(.plain)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Condition Photos card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Condition Photos")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showMediaSourceMenu = true
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .font(AppFonts.sansSerif(size: 20, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                            Text("Add Photo")
                                                .font(AppFonts.sansSerif(size: 11, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                        .frame(width: 92, height: 92)
                                        .background(AppColors.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(AppColors.gold, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    ForEach(Array(uploadedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 92, height: 92)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Button(action: {
                                                if index < uploadedImages.count {
                                                    uploadedImages.remove(at: index)
                                                }
                                                if index < selectedItems.count {
                                                    selectedItems.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, AppColors.tertiary)
                                                    .font(AppFonts.sansSerif(size: 20))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Glassmorphic Warranty card
                        if let wText = dynamicWarrantyText {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("WARRANTY")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(dynamicIsWarrantyActive ? Color(hex: 0xA3E4D7) : Color(hex: 0xF5B7B1))
                                    .kerning(1.5)
                                
                                HStack(spacing: 8) {
                                    Text(dynamicIsWarrantyActive ? "ACTIVE" : "EXPIRED")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(dynamicIsWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.6) : Color(hex: 0xC94C4C).opacity(0.6))
                                        )
                                    
                                    Text(wText)
                                        .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                ZStack {
                                    dynamicIsWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.12) : Color(hex: 0xC94C4C).opacity(0.12)
                                    Color.clear.background(.ultraThinMaterial)
                                    LinearGradient(
                                        colors: [.white.opacity(0.18), .white.opacity(0.02), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                dynamicIsWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.8) : Color(hex: 0xC94C4C).opacity(0.8),
                                                dynamicIsWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.2) : Color(hex: 0xC94C4C).opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: dynamicIsWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.25) : Color(hex: 0xC94C4C).opacity(0.25),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        
                        // Action Button
                        Button(action: {
                            guard !uploadedImages.isEmpty else {
                                errorMessage = "Please attach at least one photo."
                                return
                            }
                            guard !serial.isEmpty else { 
                                errorMessage = "Serial number is missing"
                                return 
                            }
                            isCreating = true
                            errorMessage = nil
                            
                            Task {
                                do {
                                    guard let profile = try await ProfileService().fetchCurrentProfile() else {
                                        await MainActor.run {
                                            errorMessage = "Profile not found"
                                            isCreating = false 
                                        }
                                        return
                                    }
                                    
                                    let boutiqueId: UUID
                                    if let staff = profile.1 as? StaffModel, let bid = staff.boutiqueId {
                                        boutiqueId = bid
                                    } else if let manager = profile.1 as? CorporateBoutique {
                                        boutiqueId = manager.id
                                    } else {
                                        await MainActor.run { 
                                            errorMessage = "Boutique ID not found on profile"
                                            isCreating = false 
                                        }
                                        return
                                    }
                                    
                                    guard let pid = selectedPurchase?.id ?? purchaseId else {
                                        await MainActor.run {
                                            errorMessage = "Purchase ID is missing"
                                            isCreating = false
                                        }
                                        return
                                    }
                                    
                                    let pItems = try await ASTService.shared.fetchPurchasedItems(for: client.id)
                                    let match = pItems.first(where: { $0.id == pid })
                                    let productId = match?.productId ?? pid
                                    
                                    _ = try await ASTService.shared.createAST(
                                        productId: productId,
                                        clientId: client.id,
                                        boutiqueId: boutiqueId,
                                        warrantyStatus: dynamicWarrantyText ?? "Valid",
                                        description: issue,
                                        remark: "Created via AST Intake UI. \(uploadedImages.count) photos."
                                    )
                                    
                                    await MainActor.run {
                                        created = true
                                        isCreating = false
                                        showSuccessAlert = true
                                    }
                                } catch {
                                    print("Failed to create AST: \(error)")
                                    await MainActor.run { 
                                        errorMessage = error.localizedDescription
                                        isCreating = false 
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 10) {
                                if isCreating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "wrench.and.screwdriver")
                                }
                                Text(created ? "Ticket Created" : "Create Service Ticket")
                            }
                            .font(AppFonts.sansSerif(size: 15, weight: .bold))
                            .foregroundStyle(uploadedImages.isEmpty || serial.isEmpty || isCreating ? Color.white.opacity(0.3) : AppColors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(uploadedImages.isEmpty || serial.isEmpty || isCreating ? Color.white.opacity(0.1) : AppColors.gold)
                            )
                        }
                        .disabled(uploadedImages.isEmpty || serial.isEmpty || isCreating || created)
                        
                        if let errorMsg = errorMessage {
                            Text(errorMsg)
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            // Removed custom popup, using native confirmationDialog instead
        }
        .confirmationDialog("Select Media Source", isPresented: $showMediaSourceMenu, titleVisibility: .hidden) {
            Button("Take Photo") {
                showCamera = true
            }
            Button("Choose from Library") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showPhotosPicker = true
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: selectedItems) { _, newItems in
            loadImages(from: newItems)
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItems, matching: .images)
        .sheet(isPresented: $showCamera) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(AppFonts.sansSerif(size: 50))
                        .foregroundStyle(AppColors.gold)
                    Text("Camera Modal (Placeholder)")
                        .font(AppFonts.serif(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("In a production environment, this would display the device camera capture interface.")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Dismiss") {
                        showCamera = false
                    }
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.gold)
                    .clipShape(Capsule())
                }
            }
        }
        .navigationTitle("After-Sales Intake")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Ticket Created", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("The After Sales Ticket has been successfully generated and synced.")
        }
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImages.append(uiImage)
                }
            }
            DispatchQueue.main.async {
                self.uploadedImages = loadedImages
            }
        }
    }
}


struct ASTDetails: Codable {
    let id: UUID
    let status: String
    let description: String?
    let remark: String?
    let catalogs: CatalogEntity?
    let client: ClientEntity?
}

struct AfterSalesTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let ticket = AfterSalesTicket(client: "Unknown Client", item: "Rolex Submariner Date", serial: "RLX-126610LN-8M2", issue: "Bracelet sizing", stage: .inspection, photoRequired: false)
    
    @State private var astStatus: String = "inspection"
    @State private var fetchedAST: ASTDetails? = nil
    
    private enum StageState {
        case completed
        case active
        case upcoming
    }
    
    private func rank(for status: String) -> Int {
        switch status.lowercased() {
        case "open": return 1
        case "inspection": return 2
        case "brand_review": return 3
        case "ready": return 4
        default: return 2
        }
    }
    
    private func rank(for stage: AfterSalesStage) -> Int {
        switch stage {
        case .intake: return 1
        case .inspection: return 2
        case .brandReview: return 3
        case .ready: return 4
        }
    }
    
    private func stageState(for stage: AfterSalesStage) -> StageState {
        let currentRank = rank(for: astStatus)
        let stageRank = rank(for: stage)
        
        if stage == .intake {
            return .completed
        }
        
        if astStatus.lowercased() == "ready" {
            return .completed
        }
        
        let stageStr: String
        switch stage {
        case .intake: stageStr = "open"
        case .inspection: stageStr = "inspection"
        case .brandReview: stageStr = "brand_review"
        case .ready: stageStr = "ready"
        }
        
        if astStatus.lowercased() == stageStr {
            return .active
        }
        
        if stageRank < currentRank {
            return .completed
        } else {
            return .upcoming
        }
    }
    
    private var displayStatusText: String {
        switch astStatus.lowercased() {
        case "open": return "Intake"
        case "inspection": return "Inspection"
        case "brand_review": return "Brand Review"
        case "ready": return "Ready"
        default: return "Inspection"
        }
    }
    
    private var badgeStatus: BadgeStatus {
        return astStatus.lowercased() == "ready" ? .success : .pending
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(fetchedAST?.catalogs?.name ?? "Rolex Datejust")
                                .font(AppFonts.serif(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                            Text("\(fetchedAST?.client?.name ?? "Unknown Client") · \(fetchedAST?.catalogs?.catalogId ?? ticket.serial)")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.secondary)
                            StatusBadge(text: displayStatusText, status: badgeStatus)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 12) {
                            ForEach(AfterSalesStage.allCases, id: \.self) { stage in
                                let state = stageState(for: stage)
                                HStack(spacing: 12) {
                                    Group {
                                        switch state {
                                        case .completed:
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(AppColors.success)
                                        case .active:
                                            Image(systemName: "clock.fill")
                                                .foregroundStyle(AppColors.gold)
                                        case .upcoming:
                                            Image(systemName: "circle")
                                                .foregroundStyle(.white.opacity(0.3))
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(stage.rawValue)
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(state == .upcoming ? .white.opacity(0.4) : .white)
                                        
                                        Group {
                                            switch state {
                                            case .completed:
                                                Text("Logged in immutable ticket timeline")
                                                    .foregroundStyle(AppColors.secondary)
                                            case .active:
                                                Text("Current stage")
                                                    .foregroundStyle(AppColors.gold)
                                            case .upcoming:
                                                Text("Upcoming stage")
                                                    .foregroundStyle(AppColors.secondary.opacity(0.5))
                                            }
                                        }
                                        .font(AppFonts.sansSerif(size: 11))
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .opacity(state == .upcoming ? 0.6 : 1.0)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle("Appointment Tracking")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            fetchTicketDetails()
        }
    }
    
    private func fetchTicketDetails() {
        Task {
            do {
                let catalogs: [CatalogEntity] = try await SupabaseManager.shared.client
                    .from("catalogs")
                    .select()
                    .eq("catalog_id", value: ticket.serial)
                    .execute()
                    .value
                
                if let firstCatalog = catalogs.first {
                    let astList: [ASTDetails] = try await SupabaseManager.shared.client
                        .from("ast")
                        .select("*, catalogs(*), client(*)")
                        .eq("product_id", value: firstCatalog.id.uuidString)
                        .order("id", ascending: false)
                        .execute()
                        .value
                    
                    if let firstAST = astList.first {
                        await MainActor.run {
                            self.fetchedAST = firstAST
                            self.astStatus = firstAST.status
                        }
                    }
                } else {
                    let allASTs: [ASTDetails] = try await SupabaseManager.shared.client
                        .from("ast")
                        .select("*, catalogs(*), client(*)")
                        .order("id", ascending: false)
                        .limit(1)
                        .execute()
                        .value
                    
                    if let lastAST = allASTs.first {
                        await MainActor.run {
                            self.fetchedAST = lastAST
                            self.astStatus = lastAST.status
                        }
                    }
                }
            } catch {
                print("Failed to fetch ticket details from Supabase: \(error)")
            }
        }
    }
}
