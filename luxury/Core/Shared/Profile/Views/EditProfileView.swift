import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = EditProfileViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Avatar Picker
                    VStack(spacing: 12) {
                        if let asset = viewModel.selectedPhotoAsset {
                            Image(uiImage: UIImage(data: asset.data) ?? UIImage())
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppColors.gold, lineWidth: 1))
                        } else if let urlStr = viewModel.avatarUrl, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppColors.gold, lineWidth: 1))
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(AppColors.secondary)
                        }
                        
                        PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                            Text("Change Photo")
                                .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    .padding(.top, 24)
                    
                    // Form Fields
                    VStack(spacing: 16) {
                        CustomTextField(title: "NAME", placeholder: "Name", text: $viewModel.name)
                        
                        // Email is disabled because changing email might require auth changes
                        CustomTextField(title: "EMAIL", placeholder: "Email", text: $viewModel.email)
                            .disabled(true)
                            .opacity(0.6)
                        
                        CustomTextField(title: "PHONE", placeholder: "Phone", text: $viewModel.phone)
                    }
                    .padding(.horizontal, 24)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.error)
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 40)
                    
                    CustomButton(title: "Save Changes", isLoading: viewModel.isLoading) {
                        Task {
                            await viewModel.saveProfile {
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.fetchProfile()
        }
    }
}
