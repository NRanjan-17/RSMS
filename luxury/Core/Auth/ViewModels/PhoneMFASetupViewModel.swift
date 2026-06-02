import SwiftUI
import Observation
import Supabase

enum PhoneMFAStep {
    case enterPhone
    case enterOTP
}

@Observable
final class PhoneMFASetupViewModel {
    var phoneNumber = ""
    var otpCode = ""
    var friendlyName = UIDevice.current.name
    
    var currentStep: PhoneMFAStep = .enterPhone
    var enrolledFactorId: String? = nil
    
    var isLoading = false
    var errorMessage: String?
    
    private let client = SupabaseManager.shared.client
    
    func enrollPhone() {
        guard !phoneNumber.isEmpty else {
            errorMessage = String(localized: "Phone number is required")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let formattedPhone = phoneNumber.starts(with: "+") ? phoneNumber : "+\(phoneNumber)"
                
                let params = MFAPhoneEnrollParams(friendlyName: friendlyName, phone: formattedPhone)
                let response = try await client.auth.mfa.enroll(params: params)
                
                await MainActor.run {
                    self.enrolledFactorId = response.id
                    self.currentStep = .enterOTP
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = String(localized: "Failed to send SMS: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    func verifyOTP(completion: @escaping (Bool) -> Void) {
        guard let factorId = enrolledFactorId else {
            errorMessage = String(localized: "No factor ID found. Please try again.")
            return
        }
        
        guard otpCode.count >= 6 else {
            errorMessage = String(localized: "Please enter the 6-digit code")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let params = MFAChallengeAndVerifyParams(factorId: factorId, code: otpCode)
                _ = try await client.auth.mfa.challengeAndVerify(params: params)
                
                await MainActor.run {
                    self.isLoading = false
                    completion(true)
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = String(localized: "Failed to verify code: \(error.localizedDescription)")
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
}
