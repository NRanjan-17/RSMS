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
    var client: Client? = nil
    
    @State private var clientName: String = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = "10:00 AM"
    @State private var selectedType = "Watch Consultation"
    @State private var remarks: String = ""
    @State private var isSaving = false
    @State private var errorMessage: String? = nil
    
    
    let types = AppointmentType.allCases
    
    var availableTimes: [String] {
        if Calendar.current.isDateInToday(selectedDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            let nowStr = formatter.string(from: Date())
            guard let nowTime = formatter.date(from: nowStr) else { return times }
            
            let futureTimes = times.filter { timeStr in
                if let t = formatter.date(from: timeStr) {
                    return t > nowTime
                }
                return true
            }
            return futureTimes
        }
        return times
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
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
                                if let client = client {
                                    Text(client.name)
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(.white)
                                    Spacer()
                                } else {
                                    TextField("Search for a client...", text: $clientName)
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(.white)
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
                            
                            DatePicker("Select Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppColors.gold)
                                .padding(10)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                                .fill(isDisabled ? AppColors.gold.opacity(0.5) : AppColors.gold)
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
                    .disabled(isDisabled)
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
            let clientDb = SupabaseManager.shared.client
            guard let session = try? await clientDb.auth.session else {
                throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No session"])
            }
            
            let profileService = ProfileService()
            guard let (_, staffAny) = try await profileService.fetchCurrentProfile(),
                  let staff = staffAny as? StaffModel else {
                throw NSError(domain: "Auth", code: 403, userInfo: [NSLocalizedDescriptionKey: "Staff profile not found"])
            }
            
            let timestampStr = ISO8601DateFormatter().string(from: selectedDateTime)
            
            // Conflict Check
            let existingAppointments: [AppointmentEntity] = try await clientDb.from("appointment")
                .select()
                .eq("created_by", value: staff.id)
                .eq("timestamp", value: timestampStr)
                .execute()
                .value
            
            if !existingAppointments.isEmpty {
                throw NSError(domain: "Appointment", code: 409, userInfo: [NSLocalizedDescriptionKey: "You already have an appointment scheduled for this time"])
            }
            
            guard let boutiqueId = staff.boutiqueId else {
                throw NSError(domain: "Auth", code: 403, userInfo: [NSLocalizedDescriptionKey: "Staff does not have an assigned boutique"])
            }
            
            let dbAppointmentType = selectedType.rawValue
            
            let appointment = AppointmentEntity(
                id: UUID(),
                clientId: client?.id,
                boutiqueId: boutiqueId,
                timestamp: timestampStr,
                appointmentType: AppointmentType(rawValue: selectedType) ?? .other,
                assignedTo: staff.id,
                createdBy: staff.id,
                status: .pending,
                createdAt: nil,
                remarks: remarks.isEmpty ? nil : remarks
            )
            
            try await clientDb.from("appointment").insert(appointment).execute()
            
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
