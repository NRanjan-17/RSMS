import SwiftUI

struct PhoneMFASetupView: View {
    @State private var viewModel = PhoneMFASetupViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if viewModel.currentStep == .enterPhone {
                        phoneEntryView
                    } else {
                        otpEntryView
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView()
                        .tint(AppColors.gold)
                }
            }
            .navigationTitle(viewModel.currentStep == .enterPhone ? "Phone Setup" : "Verify OTP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if viewModel.currentStep == .enterOTP {
                            viewModel.currentStep = .enterPhone
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(AppFonts.sansSerif(size: 16))
                        .foregroundStyle(AppColors.gold)
                    }
                }
            }
        }
    }
    
    private var phoneEntryView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Secure your account with an SMS verification code.")
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(AppColors.secondary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("PHONE NUMBER (with country code)")
                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1)
                
                CustomTextField(
                    title: "",
                    placeholder: "+1 234 567 8900",
                    text: $viewModel.phoneNumber
                )
                .keyboardType(.phonePad)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.error)
            }
            
            Button(action: {
                viewModel.enrollPhone()
            }) {
                Text("Send Code")
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
    }
    
    private var otpEntryView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Enter the 6-digit code sent to \(viewModel.phoneNumber)")
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(AppColors.secondary)
                .lineSpacing(4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("VERIFICATION CODE")
                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1)
                
                CustomTextField(
                    title: "",
                    placeholder: "000000",
                    text: $viewModel.otpCode
                )
                .keyboardType(.numberPad)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.error)
            }
            
            Button(action: {
                viewModel.verifyOTP { success in
                    if success {
                        dismiss()
                    }
                }
            }) {
                Text("Verify & Enable")
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
    }
}
