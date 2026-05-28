//
//  BMAppointmentDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import Supabase
import PostgREST

struct BMAppointmentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: AppointmentEntity
    
    @State private var availableStaff: [StaffModel] = []
    @State private var selectedStaffId: UUID?
    @State private var isSaving = false
    
    init(appointment: AppointmentEntity) {
        self.appointment = appointment
        _selectedStaffId = State(initialValue: appointment.assignedTo)
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
                    Text("Dashboard")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        Text("Appointment Details")
                            .font(AppFonts.serif(size: 28, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                            .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 20) {
                            HStack(spacing: 16) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(AppColors.gold08)
                                        .frame(width: 50, height: 50)
                                    Text("U")
                                        .font(AppFonts.serif(size: 20, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Unknown Client")
                                        .font(AppFonts.serif(size: 22, weight: .medium))
                                        .foregroundStyle(AppColors.text)
                                    Text(appointment.appointmentType.rawValue)
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                }
                            }

                            Divider().background(AppColors.gold15)

                            VStack(alignment: .leading, spacing: 16) {
                                DetailRow(label: "TIME",    value: appointment.formattedTime,        icon: "clock")
                                DetailRow(label: "ADVISOR", value: advisorName(for: selectedStaffId), icon: "person.fill")
                                DetailRow(label: "STORE",   value: "Maison Mumbai",         icon: "building.2.fill")
                            }
                        }
                        .padding(24)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("REASSIGN ADVISOR")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)

                            Menu {
                                ForEach(availableStaff) { staff in
                                    Button(staff.name) {
                                        selectedStaffId = staff.id
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedStaffId == nil ? "Select new advisor..." : advisorName(for: selectedStaffId))
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(selectedStaffId == nil ? AppColors.tertiary : AppColors.text)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(AppColors.gold)
                                }
                                .padding(.horizontal, 20)
                                .frame(height: 52)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 8)
                }

                VStack {
                    Button(action: {
                        Task {
                            isSaving = true
                            if let newStaffId = selectedStaffId {
                                await assignStaff(to: appointment.id, staffId: newStaffId)
                            }
                            isSaving = false
                            dismiss()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSaving ? AppColors.gold.opacity(0.5) : AppColors.gold)
                                .frame(height: 52)
                            
                            if isSaving {
                                ProgressView().tint(AppColors.background)
                            } else {
                                Text("Confirm Changes")
                                    .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                    .foregroundStyle(AppColors.background)
                            }
                        }
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                .background(AppColors.background)
            }
        }
        .task {
            await fetchAvailableStaff()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func fetchAvailableStaff() async {
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let boutique = profile as? CorporateBoutique {
                
                let fetched: [StaffModel] = try await SupabaseManager.shared.client
                    .from("staff")
                    .select()
                    .eq("boutique_id", value: boutique.id)
                    .execute()
                    .value
                
                await MainActor.run {
                    self.availableStaff = fetched
                }
            }
        } catch {
            print("Failed to fetch available staff: \(error)")
        }
    }
    
    private func advisorName(for staffId: UUID?) -> String {
        guard let staffId = staffId else { return "Unassigned" }
        return availableStaff.first(where: { $0.id == staffId })?.name ?? "Unknown"
    }
    
    private func assignStaff(to appointmentId: UUID, staffId: UUID) async {
        struct UpdateStaffRequest: Encodable {
            let assigned_to: UUID
            let status: String
        }
        do {
            try await SupabaseManager.shared.client
                .from("appointment")
                .update(UpdateStaffRequest(assigned_to: staffId, status: "assigned"))
                .eq("id", value: appointmentId)
                .execute()
        } catch {
            print("Failed to assign staff: \(error)")
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    let icon:  String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(AppColors.gold)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.tertiary)
                    .kerning(1)
                Text(value)
                    .font(AppFonts.sansSerif(size: 15, weight: .medium))
                    .foregroundStyle(AppColors.text)
            }
        }
    }
}

