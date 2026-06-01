import SwiftUI

struct PlanogramGalleryView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = PlanogramGalleryViewModel()
    let boutiqueId: UUID
    
    @State private var selectedPlanogram: PlanogramEntity?
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { router.pop() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Visual Merchandising")
                        .font(AppFonts.serif(size: 24, weight: .medium))
                        .foregroundStyle(AppColors.text)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.gold)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else if viewModel.activePlanograms.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 40))
                            .foregroundStyle(AppColors.gold)
                        Text("No active planograms.")
                            .font(AppFonts.sansSerif(size: 16))
                            .foregroundStyle(AppColors.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.activePlanograms) { planogram in
                                Button(action: {
                                    selectedPlanogram = planogram
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        AsyncImage(url: URL(string: planogram.fileUrl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 200)
                                                .clipped()
                                        } placeholder: {
                                            Rectangle()
                                                .fill(AppColors.surface)
                                                .frame(height: 200)
                                                .overlay(ProgressView().tint(AppColors.gold))
                                        }
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        Text(planogram.title)
                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.text)
                                            .lineLimit(1)
                                            .padding(.horizontal, 8)
                                        
                                        if let desc = planogram.description {
                                            Text(desc)
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.secondary)
                                                .lineLimit(2)
                                                .padding(.horizontal, 8)
                                        }
                                        Spacer().frame(height: 8)
                                    }
                                    .background(AppColors.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchPlanograms(for: boutiqueId)
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $selectedPlanogram) { planogram in
            PlanogramDetailView(planogram: planogram)
        }
    }
}
