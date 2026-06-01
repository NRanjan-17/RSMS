import SwiftUI
import PhotosUI

struct PlanogramManagementView: View {
    @State private var viewModel = PlanogramManagementViewModel()
    @State private var isShowingCreateSheet = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Planograms")
                        .font(AppFonts.serif(size: 32, weight: .medium))
                        .foregroundStyle(AppColors.text)
                    Spacer()
                    Button(action: {
                        isShowingCreateSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Planogram")
                        }
                        .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.background)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(AppColors.gold)
                        .clipShape(Capsule())
                    }
                }
                .padding(24)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.gold)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if viewModel.planograms.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.gold)
                        Text("No planograms active.")
                            .font(AppFonts.sansSerif(size: 16))
                            .foregroundStyle(AppColors.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 20)], spacing: 20) {
                            ForEach(viewModel.planograms) { planogram in
                                PlanogramAdminCard(planogram: planogram, boutiques: viewModel.boutiques) {
                                    Task {
                                        await viewModel.deletePlanogram(id: planogram.id)
                                    }
                                }
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchData()
        }
        .sheet(isPresented: $isShowingCreateSheet) {
            CreatePlanogramSheet(viewModel: viewModel)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct PlanogramAdminCard: View {
    let planogram: PlanogramEntity
    let boutiques: [CorporateBoutique]
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: planogram.fileUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(AppColors.surface)
                    .frame(height: 180)
                    .overlay(ProgressView().tint(AppColors.gold))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(planogram.title)
                        .font(AppFonts.sansSerif(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.text)
                    Spacer()
                    Menu {
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(AppColors.secondary)
                    }
                }
                
                if let desc = planogram.description {
                    Text(desc)
                        .font(AppFonts.sansSerif(size: 13))
                        .foregroundStyle(AppColors.secondary)
                        .lineLimit(2)
                }
                
                Divider().background(AppColors.gold15).padding(.vertical, 4)
                
                HStack {
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(AppColors.gold)
                        .font(.system(size: 12))
                    Text(targetStoreText)
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.tertiary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(AppColors.gold)
                        .font(.system(size: 12))
                    Text(formatDate(planogram.validUntil))
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.tertiary)
                }
            }
            .padding(16)
            .background(AppColors.background)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
    }
    
    private var targetStoreText: String {
        guard let bId = planogram.boutiqueId else { return "All Boutiques" }
        return boutiques.first(where: { $0.id == bId })?.name ?? "Unknown Boutique"
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: isoString) else { return isoString }
        let out = DateFormatter()
        out.dateStyle = .medium
        return "Valid until \(out.string(from: date))"
    }
}

struct CreatePlanogramSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: PlanogramManagementViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedBoutiqueId: UUID? = nil // nil means all
    @State private var validFrom = Date()
    @State private var validUntil = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Details").foregroundStyle(AppColors.gold)) {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $description)
                }
                .listRowBackground(AppColors.surface)
                
                Section(header: Text("Target Store").foregroundStyle(AppColors.gold)) {
                    Picker("Boutique", selection: $selectedBoutiqueId) {
                        Text("All Boutiques").tag(UUID?.none)
                        ForEach(viewModel.boutiques) { b in
                            Text(b.name).tag(Optional(b.id))
                        }
                    }
                }
                .listRowBackground(AppColors.surface)
                
                Section(header: Text("Validity").foregroundStyle(AppColors.gold)) {
                    DatePicker("Valid From", selection: $validFrom, displayedComponents: .date)
                    DatePicker("Valid Until", selection: $validUntil, displayedComponents: .date)
                }
                .listRowBackground(AppColors.surface)
                
                Section(header: Text("Image").foregroundStyle(AppColors.gold)) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text(selectedImageData == nil ? "Select Image" : "Image Selected")
                        }
                        .foregroundStyle(AppColors.gold)
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .listRowBackground(AppColors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("New Planogram")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Upload") {
                        Task {
                            guard let data = selectedImageData else { return }
                            let success = await viewModel.uploadPlanogram(
                                title: title,
                                description: description,
                                boutiqueId: selectedBoutiqueId,
                                validFrom: validFrom,
                                validUntil: validUntil,
                                imageData: data
                            )
                            if success { dismiss() }
                        }
                    }
                    .foregroundStyle(AppColors.gold)
                    .disabled(title.isEmpty || selectedImageData == nil || viewModel.isUploading)
                }
            }
            .overlay {
                if viewModel.isUploading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Uploading...")
                            .padding()
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(AppColors.gold)
                            .tint(AppColors.gold)
                    }
                }
            }
        }
    }
}
