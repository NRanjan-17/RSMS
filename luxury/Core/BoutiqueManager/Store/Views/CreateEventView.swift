//
//  CreateEventView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var eventTitle: String = ""
    @State private var eventDate = Date()
    @State private var selectedType = "Trunk Show"
    @State private var eventDescription: String = ""
    
    let eventTypes = ["Trunk Show", "VIP Preview", "Product Launch", "Private Sale"]
    
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
                    Text("Store Operations")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        Text("Create Event")
                            .font(AppFonts.serif(size: 28, weight: .semibold))
                            .foregroundStyle(AppColors.text)
                            .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EVENT TITLE")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            TextField("e.g. Winter High Jewelry Gala", text: $eventTitle)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("EVENT TYPE")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(eventTypes, id: \.self) { type in
                                        let isSelected = selectedType == type
                                        Text(type)
                                            .font(AppFonts.sansSerif(size: 12, weight: isSelected ? .medium : .light))
                                            .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(isSelected ? AppColors.gold : AppColors.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5))
                                            .onTapGesture { selectedType = type }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DATE & TIME")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            DatePicker("Select Date", selection: $eventDate)
                                .datePickerStyle(.graphical)
                                .tint(AppColors.gold)
                                .padding(10)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DESCRIPTION")
                                .font(AppFonts.sansSerif(size: 10))
                                .foregroundStyle(AppColors.gold)
                                .kerning(2)
                            
                            TextEditor(text: $eventDescription)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(.white)
                                .padding(12)
                                .frame(height: 120)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 60)
                    }
                }
                
                VStack(spacing: 0) {
                    CustomButton(title: "Launch Event", action: { dismiss() })
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                }
                .background(AppColors.background)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
