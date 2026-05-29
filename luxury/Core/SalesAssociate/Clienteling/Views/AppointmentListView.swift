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
    @State private var selectedDate = Date()
    
    @State private var selectedAppointment: AppointmentEntity?
    @State private var isShowingDetail = false
    
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
                        // Month Navigation
                        HStack {
                            Button(action: {
                                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                                    .frame(width: 32, height: 32)
                                    .background(AppColors.surface)
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            Text(viewModel.monthYearString(for: selectedDate))
                                .font(AppFonts.serif(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                                    .frame(width: 32, height: 32)
                                    .background(AppColors.surface)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Calendar Grid
                        VStack(spacing: 12) {
                            // Weekday headers
                            HStack(spacing: 0) {
                                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                    Text(day)
                                        .font(AppFonts.sansSerif(size: 11, weight: .medium))
                                        .foregroundStyle(AppColors.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            // Calendar days
                            let weeks = viewModel.weeksInMonth(for: selectedDate)
                            ForEach(0..<weeks.count, id: \.self) { weekIndex in
                                HStack(spacing: 0) {
                                    ForEach(0..<7) { dayIndex in
                                        if let day = weeks[weekIndex][dayIndex] {
                                            let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                                            let hasAppointments = viewModel.hasAppointments(on: day)
                                            let isToday = Calendar.current.isDateInToday(day)
                                            
                                            Button(action: {
                                                withAnimation {
                                                    selectedDate = day
                                                }
                                            }) {
                                                VStack(spacing: 4) {
                                                    Text("\(Calendar.current.component(.day, from: day))")
                                                        .font(AppFonts.sansSerif(size: 14, weight: isSelected ? .semibold : .regular))
                                                        .foregroundStyle(isSelected ? AppColors.background : (isToday ? AppColors.gold : AppColors.text))
                                                    
                                                    if hasAppointments {
                                                        Circle()
                                                            .fill(isSelected ? AppColors.background : AppColors.gold)
                                                            .frame(width: 4, height: 4)
                                                    } else {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 4, height: 4)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 44)
                                                .background(isSelected ? AppColors.gold : Color.clear)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            }
                                            .buttonStyle(.plain)
                                        } else {
                                            Color.clear
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 44)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        let dayAppointments = viewModel.appointmentsFor(date: selectedDate)
                        
                        if dayAppointments.isEmpty {
                            Text("No appointments for this day.")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                                .padding(.top, 40)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(spacing: 30) {
                                ForEach(dayAppointments, id: \.timeBlock) { group in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(group.timeBlock)
                                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                            .foregroundStyle(AppColors.secondary)
                                            .kerning(1.8)
                                            .padding(.horizontal, 24)
                                        
                                        VStack(spacing: 10) {
                                            ForEach(group.appointments, id: \.id) { a in
                                                Button(action: {
                                                    selectedAppointment = a
                                                    isShowingDetail = true
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
                                                            Text("U")
                                                                .font(AppFonts.serif(size: 12, weight: .semibold))
                                                                .foregroundStyle(AppColors.gold)
                                                        }
                                                        
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            HStack(spacing: 6) {
                                                                Circle()
                                                                    .fill(a.status.color)
                                                                    .frame(width: 8, height: 8)
                                                                    
                                                                if let cid = a.clientId, let ce = viewModel.clientsMap[cid] {
                                                                    Text(Client(entity: ce).name)
                                                                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                                        .foregroundStyle(AppColors.text)
                                                                } else {
                                                                    Text(a.clientId != nil ? "Client Appointment" : "Unknown Client")
                                                                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                                                        .foregroundStyle(AppColors.text)
                                                                }
                                                            }
                                                            Text(a.appointmentType.rawValue)
                                                                .font(AppFonts.sansSerif(size: 11))
                                                                .foregroundStyle(AppColors.secondary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        if a.status == .completed {
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
                                                    .background(a.status == .completed ? AppColors.surface.opacity(0.5) : AppColors.surface)
                                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(a.status == .completed ? AppColors.gold08 : AppColors.gold15, lineWidth: 0.5))
                                                    .opacity(a.status == .completed ? 0.5 : 1.0)
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
            

        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchAppointments()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(isPresented: $isShowingDetail) {
            if let appt = selectedAppointment {
                AppointmentDetailSheet(appointment: appt, viewModel: viewModel)
            }
        }
    }
}

struct AppointmentDetailSheet: View {
    let appointment: AppointmentEntity
    let viewModel: AppointmentsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @State private var clientEntity: ClientEntity?
    @State private var isLoadingClient = false
    @State private var currentStatus: AppointmentStatus
    
    init(appointment: AppointmentEntity, viewModel: AppointmentsViewModel) {
        self.appointment = appointment
        self.viewModel = viewModel
        _currentStatus = State(initialValue: appointment.status)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Appointment Details")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.tertiary)
                    }
                }
                .padding(.top, 24)
                
                // Details Card
                VStack(spacing: 16) {
                    detailRow(title: "Time", value: "\(appointment.formattedDate) at \(appointment.formattedTime)")
                    Divider().background(AppColors.border)
                    detailRow(title: "Type", value: appointment.appointmentType.rawValue)
                    Divider().background(AppColors.border)
                    
                    HStack {
                        Text("Status")
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.secondary)
                        Spacer()
                        Picker("Status", selection: $currentStatus) {
                            ForEach(AppointmentStatus.allCases, id: \.self) { status in
                                Text(status.rawValue.capitalized).tag(status)
                            }
                        }
                        .tint(AppColors.gold)
                        .onChange(of: currentStatus) { _, newValue in
                            Task {
                                await viewModel.updateAppointmentStatus(appointmentId: appointment.id, newStatus: newValue)
                                await MainActor.run {
                                    dismiss()
                                }
                            }
                        }
                    }
                    
                    if let remarks = appointment.remarks, !remarks.isEmpty {
                        Divider().background(AppColors.border)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Remarks")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.secondary)
                            Text(remarks)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(20)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                
                // Client Card
                if isLoadingClient {
                    ProgressView()
                        .tint(AppColors.gold)
                        .padding()
                } else if let ce = clientEntity {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("CLIENT")
                            .font(AppFonts.sansSerif(size: 10, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        HStack(spacing: 12) {
                            let clientModel = Client(entity: ce)
                            ZStack {
                                Circle().fill(AppColors.gold08).frame(width: 40, height: 40)
                                Text(clientModel.initial)
                                    .font(AppFonts.serif(size: 16, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(clientModel.name)
                                    .font(AppFonts.sansSerif(size: 16, weight: .medium))
                                    .foregroundStyle(.white)
                                Text(clientModel.tier.rawValue)
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.gold)
                            }
                            Spacer()
                        }
                        
                        Button(action: {
                            dismiss()
                            // Slight delay to let sheet dismiss before pushing new view
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                let clientModel = Client(entity: ce)
                                router.push(SARoute.clientProfile(clientModel))
                            }
                        }) {
                            Text("Open Full Profile")
                                .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                                .foregroundStyle(AppColors.background)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.gold)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(20)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                } else if appointment.clientId != nil {
                    Text("Could not load client details.")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.error)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .task {
            if let clientId = appointment.clientId {
                isLoadingClient = true
                do {
                    clientEntity = try await ClientService().fetchClient(id: clientId)
                } catch {
                    print("Error fetching client: \(error)")
                }
                isLoadingClient = false
            }
        }
    }
    
    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppFonts.sansSerif(size: 14))
                .foregroundStyle(AppColors.secondary)
            Spacer()
            Text(value)
                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}
