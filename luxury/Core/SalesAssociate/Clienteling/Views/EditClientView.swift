//
//  EditClientView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct EditClientView: View {
    @Environment(\.dismiss) private var dismiss
    let client: Client
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var mobile: String = ""
    @State private var email: String = ""
    @State private var selectedTier: String = ""
    
    @State private var marketingConsent: Bool = true
    @State private var dataConsent: Bool = true
    @State private var thirdPartyConsent: Bool = false
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showErrorAlert = false
    @State private var clientEntity: ClientEntity? = nil
    
    private let clientService = ClientService()
    
    init(client: Client) {
        self.client = client
        let nameParts = client.name.components(separatedBy: " ")
        _firstName = State(initialValue: nameParts.first ?? "")
        _lastName = State(initialValue: nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : "")
        _selectedTier = State(initialValue: client.tier.rawValue)
        
        if let clientEmail = client.email, !clientEmail.isEmpty {
            _email = State(initialValue: clientEmail)
        } else {
            let emailPrefix = nameParts.first?.lowercased() ?? "client"
            _email = State(initialValue: "\(emailPrefix)@example.com")
        }
        
        if let clientPhone = client.phone, !clientPhone.isEmpty {
            _mobile = State(initialValue: clientPhone)
        } else {
            _mobile = State(initialValue: "+91 98210 54321")
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Client Profile")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    
                    Spacer()
                    
                    Button("Save") {
                        updateClient()
                    }
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.gold)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Edit Client")
                            .font(AppFonts.serif(size: 28, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PERSONAL INFORMATION")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            HStack(spacing: 10) {
                                RSMSField(label: "First Name", placeholder: "e.g. Rahul", text: $firstName)
                                RSMSField(label: "Last Name", placeholder: "e.g. Bajaj", text: $lastName)
                            }
                            
                            RSMSField(label: "Mobile", placeholder: "+91 98XXX XXXXX", text: $mobile)
                            RSMSField(label: "Email", placeholder: "client@email.com", text: $email)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TIER")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                                .padding(.top, 4)
                            
                            HStack(spacing: 8) {
                                let tiers = ["Standard", "VIP", "UHNW"]
                                ForEach(tiers, id: \.self) { t in
                                    let isSelected = selectedTier == t
                                    Text(t)
                                        .font(AppFonts.sansSerif(size: 13, weight: isSelected ? .medium : .light))
                                        .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(isSelected ? AppColors.gold : Color.clear)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5))
                                        .onTapGesture {
                                            withAnimation { selectedTier = t }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRIVACY CONSENTS")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            VStack(spacing: 8) {
                                Group {
                                    Toggle(isOn: $marketingConsent) {
                                        Text("Marketing Communications")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                    Toggle(isOn: $dataConsent) {
                                        Text("Data Processing & Storage")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                    Toggle(isOn: $thirdPartyConsent) {
                                        Text("Third-Party Sharing")
                                            .font(AppFonts.sansSerif(size: 13))
                                            .foregroundStyle(AppColors.text)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 11)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.gold15, lineWidth: 0.5))
                                .toggleStyle(LuxuryToggleStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        
                        Button(action: {}) {
                            Text("Deactivate Client Profile")
                                .font(AppFonts.sansSerif(size: 13))
                                .foregroundStyle(AppColors.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.error.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.error.opacity(0.3), lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                
                VStack(spacing: 0) {
                    CustomButton(title: "Save Changes", isLoading: isLoading, action: { updateClient() })
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .padding(.bottom, 38)
                }
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await loadClientData()
        }
        .alert("Error Saving Client", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadClientData() async {
        isLoading = true
        do {
            let entity = try await clientService.fetchClient(id: client.id)
            await MainActor.run {
                self.clientEntity = entity
                self.firstName = entity.name.components(separatedBy: " ").first ?? ""
                self.lastName = entity.name.components(separatedBy: " ").dropFirst().joined(separator: " ")
                self.email = entity.email
                self.mobile = entity.phone ?? ""
                self.selectedTier = entity.tier ?? "Standard"
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                print("Error loading client from database: \(error)")
            }
        }
    }
    
    private func updateClient() {
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedMobile = mobile.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirst.isEmpty else {
            errorMessage = "First name is required."
            showErrorAlert = true
            return
        }
        
        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email is required."
            showErrorAlert = true
            return
        }
        
        let fullName = trimmedLast.isEmpty ? trimmedFirst : "\(trimmedFirst) \(trimmedLast)"
        
        let updatedEntity = ClientEntity(
            id: client.id,
            name: fullName,
            email: trimmedEmail,
            phone: trimmedMobile.isEmpty ? nil : trimmedMobile,
            dob: clientEntity?.dob,
            tier: selectedTier,
            productsPurchased: clientEntity?.productsPurchased ?? [],
            createdAt: clientEntity?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        isLoading = true
        Task {
            do {
                try await clientService.updateClient(updatedEntity)
                await MainActor.run {
                    isLoading = false
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshClients"), object: nil)
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

private struct RSMSField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.sansSerif(size: 10))
                .foregroundStyle(AppColors.secondary)
                .kerning(0.8)
                .textCase(.uppercase)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppColors.tertiary))
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .frame(height: 46)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
        }
    }
}
