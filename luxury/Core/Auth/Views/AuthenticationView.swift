import SwiftUI

struct AuthenticationView: View {
    let selectedRole: UserRole
    var onBack: () -> Void
    var onSignInSuccess: () -> Void
    
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = AuthViewModel()
    @State private var showComingSoon = false
    
    var body: some View {
        @Bindable var authVM = viewModel
        
        ZStack {
            AppColors.background
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.vertical, 20)
                        }
                        
                        Text("Verify\nIdentity.")
                            .font(AppFonts.serif(size: 52, weight: .light))
                            .italic()
                            .foregroundStyle(AppColors.text)
                            .lineSpacing(-5)
                            .padding(.bottom, 16)
                        
                        Text("Signing in as \(roleTitle)")
                            .font(AppFonts.sansSerif(size: 13, weight: .light))
                            .foregroundStyle(AppColors.secondary)
                            .padding(.bottom, 40)
                    }
                    
                    VStack(spacing: 20) {
                        CustomTextField(
                            title: "EMAIL ADDRESS",
                            placeholder: "name@luxury.com",
                            text: $authVM.email,
                            keyboardType: .emailAddress
                        )
                        
                        CustomSecureField(
                            title: "PASSWORD",
                            placeholder: "••••••••",
                            text: $authVM.password
                        )
                    }
                    .padding(.bottom, 12)
                    
                    HStack {
                        Spacer()
                        Button(action: { authVM.resetPassword() }) {
                            Text("Forgot Password?")
                                .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    .padding(.bottom, 32)
                    
                    VStack(spacing: 16) {
                        if let error = authVM.errorMessage {
                            Text(error)
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.error)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        
                        CustomButton(
                            title: "Sign In",
                            isLoading: authVM.isLoading,
                            action: {
                                authVM.authenticate(selectedRole: selectedRole) {
                                    onSignInSuccess()
                                }
                            }
                        )
                    }
                    
                    if selectedRole != .corporateAdmin {
                        HStack(spacing: 14) {
                            Rectangle().fill(AppColors.tertiary).frame(height: 0.5)
                            Text("or continue with")
                                .font(AppFonts.sansSerif(size: 11))
                                .foregroundStyle(AppColors.tertiary)
                            Rectangle().fill(AppColors.tertiary).frame(height: 0.5)
                        }
                        .padding(.vertical, 24)
                        
                        SocialButton(icon: "apple.logo", title: "Sign in with Apple") {
                            showComingSoon = true
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 28)
            }
        }
        .alert("Coming Soon", isPresented: $showComingSoon) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This feature will be available soon.")
        }
        .alert("Reset Link Sent", isPresented: $authVM.showResetSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A password reset link has been sent to your email address.")
        }
    }
    
    private var roleTitle: String {
        switch selectedRole {
        case .salesAssociate: return "Sales Associate"
        case .boutiqueManager: return "Boutique Manager"
        case .inventoryController: return "Inventory Controller"
        case .corporateAdmin: return "Corporate Admin"
        }
    }
}

private struct CustomTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                .foregroundStyle(AppColors.secondary)
                .kerning(1.5)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.tertiary))
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(AppColors.text)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.none)
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.gold15, lineWidth: 1)
                )
        }
    }
}

private struct CustomSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                .foregroundStyle(AppColors.secondary)
                .kerning(1.5)
            
            SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.tertiary))
                .font(AppFonts.sansSerif(size: 15))
                .foregroundStyle(AppColors.text)
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.gold15, lineWidth: 1)
                )
        }
    }
}

private struct SocialButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if icon == "google.logo" {
                    Image(systemName: "g.circle.fill")
                } else {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(AppFonts.sansSerif(size: 14, weight: .medium))
            }
            .foregroundStyle(AppColors.text)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.gold15, lineWidth: 1)
            )
        }
    }
}
