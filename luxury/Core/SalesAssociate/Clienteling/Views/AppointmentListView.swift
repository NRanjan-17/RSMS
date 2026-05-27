//
//  AppointmentListView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct AppointmentListView: View {
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AppointmentsViewModel()
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    
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
                        .font(AppFonts.serif(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.currentMonthDays, id: \.0) { day in
                                    let isSelected = selectedDay == day.0
                                    VStack(spacing: 5) {
                                        Text(day.1)
                                            .font(AppFonts.sansSerif(size: 10, weight: .light))
                                            .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                        Text(day.2)
                                            .font(AppFonts.serif(size: 18, weight: .semibold))
                                            .foregroundStyle(isSelected ? AppColors.background : AppColors.text)
                                    }
                                    .frame(width: 48)
                                    .padding(.vertical, 9)
                                    .background(isSelected ? AppColors.gold : AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5))
                                    .onTapGesture {
                                        withAnimation { selectedDay = day.0 }
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Text("TODAY · \(viewModel.remainingCount) REMAINING")
                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                            .kerning(2)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 10) {
                            let appts = viewModel.appointments
                            ForEach(appts, id: \.id) { a in
                                Button(action: {
                                    router.push(SARoute.clientProfile(ClientDetailViewModel.defaultClient))
                                }) {
                                    HStack(spacing: 12) {
                                        Text(a.formattedTime)
                                            .font(AppFonts.sansSerif(size: 10, weight: .medium))
                                            .foregroundStyle(AppColors.gold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(AppColors.gold08)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppColors.gold08)
                                                .frame(width: 34, height: 34)
                                            Text(String(a.client?.name.prefix(1) ?? "U").uppercased())
                                                .font(AppFonts.serif(size: 12, weight: .semibold))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            HStack(spacing: 6) {
                                                Text(a.client?.name ?? "Unknown Client")
                                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                    .foregroundStyle(AppColors.text)
                                                if let tier = a.client?.tier {
                                                    StatusBadge(text: tier, status: .neutral)
                                                }
                                            }
                                            Text(a.appointmentType)
                                                .font(AppFonts.sansSerif(size: 11))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if a.status == "completed" {
                                            ZStack {
                                                Circle().fill(AppColors.success.opacity(0.15)).frame(width: 20, height: 20)
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundStyle(AppColors.success)
                                            }
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundStyle(AppColors.tertiary)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(a.status == "completed" ? AppColors.surface.opacity(0.5) : AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(a.status == "completed" ? AppColors.gold08 : AppColors.gold15, lineWidth: 0.5))
                                    .opacity(a.status == "completed" ? 0.5 : 1.0)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("UPCOMING")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.8)
                                .padding(.horizontal, 24)
                            
                            Button(action: {
                                router.push(SARoute.clientProfile(ClientDetailViewModel.defaultClient))
                            }) {
                                HStack(spacing: 12) {
                                    Text("Thu 15")
                                        .font(AppFonts.sansSerif(size: 10, weight: .medium))
                                        .foregroundStyle(AppColors.gold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppColors.gold08)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 6) {
                                            Text("Unknown Client")
                                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                .foregroundStyle(AppColors.text)
                                            StatusBadge(text: "UHNW", status: .success)
                                        }
                                        Text("Hermès Spring Consultation · 11:00 AM")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        router.presentFullScreen(SARoute.createAppointment)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppColors.gold)
                                .frame(width: 48, height: 48)
                                .shadow(color: AppColors.gold.opacity(0.3), radius: 10, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(AppColors.background)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
