//
//  BMAllAppointmentsView.swift
//  luxury
//
//  Created by Nalinish Ranjan on 15/05/26.
//

import SwiftUI
import Supabase
import PostgREST

struct BMAllAppointmentsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    
    @State private var appointments: [AppointmentEntity] = []
    @State private var availableStaff: [StaffModel] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "All Appointments", showBackButton: true, backAction: {
                    dismiss()
                })
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.gold)
                    Spacer()
                } else if appointments.isEmpty {
                    Spacer()
                    Text("No appointments found")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(appointments) { appointment in
                                Button(action: {
                                    router.presentFullScreen(BMRoute.appointmentDetail(appointment))
                                }) {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(appointment.formattedTime)
                                                .font(AppFonts.sansSerif(size: 14, weight: .bold))
                                                .foregroundStyle(AppColors.gold)
                                            Text(appointment.displayAppointmentType.uppercased())
                                                .font(AppFonts.sansSerif(size: 8, weight: .bold))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                        .frame(width: 70, alignment: .leading)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(appointment.client?.name ?? "Unknown Client")
                                                .font(AppFonts.serif(size: 17, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            Text("Advisor: \(advisorName(for: appointment.assignedTo))")
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    .padding(20)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.gold15, lineWidth: 0.5)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        await fetchAppointments()
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await fetchStaff()
            await fetchAppointments()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("RefreshAppointments"))) { _ in
            Task {
                await fetchAppointments()
            }
        }
    }
    
    private func fetchStaff() async {
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
            print("Failed to fetch staff: \(error)")
        }
    }
    
    private func fetchAppointments() async {
        do {
            if let (_, profile) = try await ProfileService().fetchCurrentProfile(),
               let boutique = profile as? CorporateBoutique {
                
                let fetched: [AppointmentEntity] = try await SupabaseManager.shared.client
                    .from("appointment")
                    .select("*, client(*)")
                    .eq("boutique_id", value: boutique.id)
                    .order("timestamp", ascending: false) // Newest first
                    .execute()
                    .value
                
                await MainActor.run {
                    self.appointments = fetched
                    self.isLoading = false
                }
            }
        } catch {
            print("Failed to fetch all appointments: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func advisorName(for staffId: UUID?) -> String {
        guard let staffId = staffId else { return "Unassigned" }
        return availableStaff.first(where: { $0.id == staffId })?.name ?? "Unknown"
    }
}
