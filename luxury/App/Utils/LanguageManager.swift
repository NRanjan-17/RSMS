import SwiftUI

/// A manager to handle app-wide language overrides.
@Observable
final class LanguageManager {
    static let shared = LanguageManager()
    
    var selectedLanguage: String {
        get { UserDefaults.standard.string(forKey: "selectedLanguage") ?? "" }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedLanguage")
            // To trigger SwiftUI updates, we can just use a regular stored property
            // or rely on the environment refresh. 
            // For @Observable, it's easiest to have a published tracker variable.
            trigger = UUID()
        }
    }
    
    // Hidden property just to trigger @Observable updates
    private var trigger = UUID()
    
    var currentLocale: Locale {
        _ = trigger // depend on trigger
        if selectedLanguage.isEmpty {
            return Locale.current
        } else {
            return Locale(identifier: selectedLanguage)
        }
    }
    
    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
    }
}
