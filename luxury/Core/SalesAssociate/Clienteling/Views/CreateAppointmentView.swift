//
//  CreateAppointmentView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import Supabase
import Auth

struct CreateAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var clients: [ClientEntity] = []
    @State private var selectedClient: ClientEntity? = nil
    @State private var isLoadingClients = false
    @State private var selectedDateTime = Date()
    @State private var selectedType = AppointmentType.inStore
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    
    
    let types = AppointmentType.allCases
    
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
                    Text("Appointments")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        Text("New Appointment")
                            .font(AppFonts.serif(size: 28, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                            .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CLIENT")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(AppColors.tertiary)
                                Menu {
                                    ForEach(clients, id: \.id) { client in
                                        Button(action: {
                                            selectedClient = client
                                        }) {
                                            Text(client.name)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedClient?.name ?? "Select a client...")
                                            .font(AppFonts.sansSerif(size: 14))
                                            .foregroundStyle(selectedClient == nil ? AppColors.tertiary : .white)
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .foregroundStyle(AppColors.tertiary)
                                            .font(.system(size: 12))
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 50)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DATE & TIME")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            DatePicker("Select Date & Time", selection: $selectedDateTime, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.graphical)
                                .tint(AppColors.gold)
                                .padding(10)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("CONSULTATION TYPE")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            VStack(spacing: 1) {
                                ForEach(types, id: \.self) { type in
                                    let isSelected = selectedType == type
                                    HStack {
                                        Text(type.displayName)
                                            .font(AppFonts.sansSerif(size: 14))
                                            .foregroundStyle(isSelected ? AppColors.gold : AppColors.text)
                                        Spacer()
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(height: 52)
                                    .background(AppColors.surface)
                                    .onTapGesture { selectedType = type }
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }
                
                VStack(spacing: 0) {
                    if let error = errorMessage {
                        Text(error)
                            .font(AppFonts.sansSerif(size: 12))
                            .foregroundStyle(AppColors.error)
                            .padding(.bottom, 8)
                    }
                    
                    Button(action: {
                        Task { await saveAppointment() }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedClient == nil || isSaving ? AppColors.gold.opacity(0.5) : AppColors.gold)
                                .frame(height: 52)
                            
                            if isSaving {
                                ProgressView()
                                    .tint(AppColors.background)
                            } else {
                                Text("Confirm Appointment")
                                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.background)
                            }
                        }
                    }
                    .disabled(selectedClient == nil || isSaving)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .background(AppColors.background)
            }
        }
        .task {
            await fetchClients()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func fetchClients() async {
        isLoadingClients = true
        do {
            let service = ClientService()
            let fetched = try await service.fetchClients()
            await MainActor.run {
                self.clients = fetched
            }
        } catch {
            print("Failed to fetch clients: \(error)")
        }
        await MainActor.run {
            isLoadingClients = false
        }
    }
    
    private func saveAppointment() async {
        isSaving = true
        errorMessage = nil
        
        do {
            let client = SupabaseManager.shared.client
            guard (try? await client.auth.session) != nil else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No session"])
            }
            
            let profileService = ProfileService()
            guard let (_, staffAny) = try await profileService.fetchCurrentProfile(),
                  let staff = staffAny as? StaffModel else {
                throw NSError(domain: "Auth", code: 403, userInfo: [NSLocalizedDescriptionKey: "Staff profile not found"])
            }
            
            let timestampStr = ISO8601DateFormatter().string(from: selectedDateTime)
            
            guard let boutiqueId = staff.boutiqueId else {
                throw NSError(domain: "Auth", code: 403, userInfo: [NSLocalizedDescriptionKey: "Staff does not have an assigned boutique"])
            }
            
            let dbAppointmentType = selectedType.rawValue
            
            let appointment = AppointmentEntity(
                id: UUID(),
                clientId: selectedClient?.id,
                boutiqueId: boutiqueId,
                timestamp: timestampStr,
                appointmentType: dbAppointmentType,
                assignedTo: staff.id,
                createdBy: staff.id,
                status: "pending",
                createdAt: nil
            )
            
            try await client.from("appointment").insert(appointment).execute()
            
            await MainActor.run {
                dismiss()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isSaving = false
        }
    }
}
