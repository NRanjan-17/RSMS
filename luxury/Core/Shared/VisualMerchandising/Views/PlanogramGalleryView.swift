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
                    VStack(spacing: 16) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 60, weight: .light))
                            .foregroundStyle(AppColors.gold.opacity(0.8))
                        Text("No active planograms")
                            .font(AppFonts.serif(size: 24, weight: .medium))
                            .foregroundStyle(AppColors.text)
                        Text("There are no visual merchandising guidelines available for this boutique at the moment.")
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
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
                                        CachedAsyncImage(url: URL(string: planogram.fileUrl)) { image in
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
                                        
                                        Text(planogram.title)
                                            .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                            .foregroundStyle(AppColors.text)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.top, 4)
                                        
                                        if let desc = planogram.description {
                                            Text(desc)
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.secondary)
                                                .lineLimit(2)
                                                .padding(.horizontal, 12)
                                        }
                                        Spacer().frame(height: 8)
                                    }
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
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
