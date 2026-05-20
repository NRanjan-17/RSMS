//
//  CreateAppointmentView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct CreateAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var clientName: String = ""
    @State private var selectedDate = Date()
    @State private var selectedTime = "10:00 AM"
    @State private var selectedType = "Watch Consultation"
    
    let times = ["10:00 AM", "11:30 AM", "01:00 PM", "02:30 PM", "04:00 PM", "05:30 PM"]
    let types = ["Watch Consultation", "Jewellery Fitting", "Leather Goods Preview", "Video Consult"]
    
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
                                TextField("Search for a client...", text: $clientName)
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(.white)
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
                            
                            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppColors.gold)
                                .padding(10)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(times, id: \.self) { time in
                                        let isSelected = selectedTime == time
                                        Text(time)
                                            .font(AppFonts.sansSerif(size: 12, weight: isSelected ? .medium : .light))
                                            .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(isSelected ? AppColors.gold : AppColors.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5))
                                            .onTapGesture { selectedTime = time }
                                    }
                                }
                            }
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
                                        Text(type)
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
                    CustomButton(title: "Confirm Appointment", action: { dismiss() })
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
