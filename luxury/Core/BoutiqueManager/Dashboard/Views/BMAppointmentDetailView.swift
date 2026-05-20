//
//  BMAppointmentDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct BMAppointmentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let appointment: BMAppointment
    
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
                                    Text(appointment.clientName.prefix(1))
                                        .font(AppFonts.serif(size: 20, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(appointment.clientName)
                                        .font(AppFonts.serif(size: 22, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(appointment.type)
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                }
                            }
                            
                            Divider().background(AppColors.gold15)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                DetailRow(label: "TIME", value: appointment.time, icon: "clock")
                                DetailRow(label: "ADVISOR", value: appointment.advisorName, icon: "person.fill")
                                DetailRow(label: "STORE", value: "Maison Mumbai", icon: "building.2.fill")
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
                            
                            HStack {
                                Text("Select new advisor...")
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.tertiary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 52)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 8)
                }
                
                VStack {
                    CustomButton(title: "Confirm Changes", action: { dismiss() })
                        .padding(.horizontal, 24)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.gold)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.tertiary)
                    .kerning(1)
                Text(value)
                    .font(AppFonts.sansSerif(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
        }
    }
}
