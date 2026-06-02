//
//  BMPendingAppointmentsListView.swift
//  luxury
//
//  Created by AutoAgent on 03/06/26.
//

import SwiftUI

struct BMPendingAppointmentsListView: View {
    @Environment(Router.self) private var router
    let appointments: [AppointmentEntity]
    
    @State private var searchText = ""
    
    var filteredAppointments: [AppointmentEntity] {
        if searchText.isEmpty {
            return appointments
        } else {
            return appointments.filter {
                ($0.client?.name.localizedCaseInsensitiveContains(searchText) == true) ||
                $0.displayAppointmentType.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header & Search
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            router.pop()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(AppFonts.sansSerif(size: 20))
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing, 8)
                        
                        Text("Pending Appointments")
                            .font(AppFonts.serif(size: 28, weight: .bold))
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search by client or type", text: $searchText)
                            .font(AppFonts.sansSerif(size: 16))
                            .foregroundStyle(.white)
                            .tint(AppColors.gold)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(AppColors.tertiary)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 1))
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if filteredAppointments.isEmpty {
                            Text("No pending appointments found.")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.tertiary)
                                .padding(.horizontal, 24)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredAppointments) { appointment in
                                    Button(action: {
                                        router.push(BMRoute.appointmentDetail(appointment))
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
                                                Text("Unassigned - Needs Approval")
                                                    .font(AppFonts.sansSerif(size: 12))
                                                    .foregroundStyle(AppColors.warning)
                                            }
                                            
                                            Spacer()
                                            
                                            Text("Review")
                                                .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                                .foregroundStyle(AppColors.background)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(AppColors.gold)
                                                .clipShape(Capsule())
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
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}
