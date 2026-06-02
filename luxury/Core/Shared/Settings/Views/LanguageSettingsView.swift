import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Environment(\.dismiss) private var dismiss
    
    // Define available languages
    let availableLanguages = [
        ("System Default", ""),
        // Major World Languages
        ("English", "en"),
        ("French", "fr"),
        ("German", "de"),
        ("Spanish", "es"),
        ("Chinese (Simplified)", "zh-Hans"),
        ("Chinese (Traditional)", "zh-Hant"),
        ("Japanese", "ja"),
        ("Korean", "ko"),
        ("Arabic", "ar"),
        ("Russian", "ru"),
        ("Portuguese", "pt"),
        ("Italian", "it"),
        // Indian Languages
        ("Hindi", "hi"),
        ("Bengali", "bn"),
        ("Telugu", "te"),
        ("Marathi", "mr"),
        ("Tamil", "ta"),
        ("Urdu", "ur"),
        ("Gujarati", "gu"),
        ("Kannada", "kn"),
        ("Odia", "or"),
        ("Malayalam", "ml"),
        ("Punjabi", "pa"),
        ("Assamese", "as")
    ]
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Text("Language")
                        .font(AppFonts.serif(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    Spacer()
                    // Invisible spacer for balance
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(availableLanguages, id: \.1) { language in
                            Button(action: {
                                languageManager.setLanguage(language.1)
                            }) {
                                HStack {
                                    Text(language.0)
                                        .font(AppFonts.sansSerif(size: 16))
                                        .foregroundStyle(languageManager.selectedLanguage == language.1 ? AppColors.gold : .white)
                                    Spacer()
                                    if languageManager.selectedLanguage == language.1 {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                    }
                                }
                                .padding(16)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(languageManager.selectedLanguage == language.1 ? AppColors.gold : AppColors.gold15, lineWidth: 0.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
