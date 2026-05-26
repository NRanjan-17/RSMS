//
//  AfterSalesViews.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import PhotosUI

struct AfterSalesIntakeView: View {
    @Environment(\.dismiss) private var dismiss
    
    let clientName: String?
    let serialNumber: String?
    let isWarrantyActive: Bool
    
    @State private var serial: String
    @State private var issue = "Bracelet sizing and clasp stiffness"
    @State private var created = false
    
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var showMediaSourceMenu = false
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var uploadedImages: [UIImage] = []
    
    init(clientName: String? = nil, serialNumber: String? = nil, isWarrantyActive: Bool = true) {
        self.clientName = clientName
        self.serialNumber = serialNumber
        self.isWarrantyActive = isWarrantyActive
        self._serial = State(initialValue: serialNumber ?? "RLX-126610LN-8M2")
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 44, height: 44)
                    }
                    Text("After-Sales Intake")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        StatusBadge(
                            text: created ? "Ticket Created" : (uploadedImages.isEmpty ? "Photo Required" : "Ready to Create"),
                            status: created ? .success : (uploadedImages.isEmpty ? .warning : .pending)
                        )
                        
                        // Client enclosed card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Client")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            Text(clientName != nil ? "\(clientName!) · UHNW · Appointment linked" : "Rahul Bajaj · UHNW · Appointment linked")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Serial Number enclosed card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Serial Number")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            TextField("Serial or manual item entry", text: $serial)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .textFieldStyle(.plain)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Service Details enclosed card
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Service Details")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            TextField("Issue and condition notes", text: $issue, axis: .vertical)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .textFieldStyle(.plain)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Condition Photos enclosed card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Condition Photos")
                                .font(AppFonts.serif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.gold)
                                .kerning(0.5)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            showMediaSourceMenu = true
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                            Text("Add Photo")
                                                .font(AppFonts.sansSerif(size: 11, weight: .medium))
                                                .foregroundStyle(AppColors.gold)
                                        }
                                        .frame(width: 92, height: 92)
                                        .background(AppColors.surface2)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(AppColors.gold, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    
                                    ForEach(Array(uploadedImages.enumerated()), id: \.offset) { index, image in
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 92, height: 92)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                            Button(action: {
                                                if index < uploadedImages.count {
                                                    uploadedImages.remove(at: index)
                                                }
                                                if index < selectedItems.count {
                                                    selectedItems.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundStyle(.white, AppColors.tertiary)
                                                    .font(.system(size: 20))
                                                    .padding(4)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Glassmorphic Warranty card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WARRANTY")
                                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                .foregroundStyle(isWarrantyActive ? Color(hex: 0xA3E4D7) : Color(hex: 0xF5B7B1))
                                .kerning(1.5)
                            
                            HStack(spacing: 8) {
                                Text(isWarrantyActive ? "ACTIVE" : "EXPIRED")
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(isWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.6) : Color(hex: 0xC94C4C).opacity(0.6))
                                    )
                                
                                Text(isWarrantyActive ? "Valid until 24 nov 2026" : "Expired on 24 nov 2026")
                                    .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            ZStack {
                                // Translucent base
                                isWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.12) : Color(hex: 0xC94C4C).opacity(0.12)
                                
                                // Blur
                                Color.clear.background(.ultraThinMaterial)
                                
                                // Highlight reflection
                                LinearGradient(
                                    colors: [.white.opacity(0.18), .white.opacity(0.02), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            isWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.8) : Color(hex: 0xC94C4C).opacity(0.8),
                                            isWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.2) : Color(hex: 0xC94C4C).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(
                            color: isWarrantyActive ? Color(hex: 0x3D9E6A).opacity(0.25) : Color(hex: 0xC94C4C).opacity(0.25),
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                        
                        // Action Button
                        Button(action: {
                            created = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "wrench.and.screwdriver")
                                Text(created ? "Ticket RSMS-AS-1042 Created" : "Create Service Ticket")
                            }
                            .font(AppFonts.sansSerif(size: 15, weight: .bold))
                            .foregroundStyle(uploadedImages.isEmpty ? Color.white.opacity(0.3) : AppColors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(uploadedImages.isEmpty ? Color.white.opacity(0.1) : AppColors.gold)
                            )
                        }
                        .disabled(uploadedImages.isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
            
            // Dimmed background overlay + Custom Floating popup
            if showMediaSourceMenu {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMediaSourceMenu = false
                        }
                    }
                    .transition(.opacity)
                
                // Centered Floating Popup Card
                VStack(alignment: .leading, spacing: 0) {
                    Text("Select Media Source")
                        .font(AppFonts.serif(size: 15, weight: .bold))
                        .foregroundStyle(AppColors.gold)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    
                    Divider()
                        .background(AppColors.border)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMediaSourceMenu = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showCamera = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .foregroundStyle(AppColors.gold)
                            Text("Take Photo")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .background(AppColors.border)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMediaSourceMenu = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showPhotosPicker = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(AppColors.gold)
                            Text("Choose from Library")
                                .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .background(AppColors.border)
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showMediaSourceMenu = false
                        }
                    }) {
                        Text("Cancel")
                            .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: 280)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.gold.opacity(0.35), lineWidth: 1.5)
                )
                .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 10)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .onChange(of: selectedItems) { _, newItems in
            loadImages(from: newItems)
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItems, matching: .images)
        .sheet(isPresented: $showCamera) {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(AppColors.gold)
                    Text("Camera Modal (Placeholder)")
                        .font(AppFonts.serif(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("In a production environment, this would display the device camera capture interface.")
                        .font(AppFonts.sansSerif(size: 14))
                        .foregroundStyle(AppColors.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button("Dismiss") {
                        showCamera = false
                    }
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(AppColors.background)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.gold)
                    .clipShape(Capsule())
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImages.append(uiImage)
                }
            }
            DispatchQueue.main.async {
                self.uploadedImages = loadedImages
            }
        }
    }
}


struct AfterSalesTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let ticket = AfterSalesTicket(client: "Rahul Bajaj", item: "Rolex Submariner Date", serial: "RLX-126610LN-8M2", issue: "Bracelet sizing", stage: .inspection, photoRequired: false)
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                            .frame(width: 44, height: 44)
                    }
                    Text("Ticket Tracking")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(ticket.item)
                                .font(AppFonts.serif(size: 22, weight: .medium))
                                .foregroundStyle(.white)
                            Text("\(ticket.client) · \(ticket.serial)")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.secondary)
                            StatusBadge(text: ticket.stage.rawValue, status: .pending)
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(spacing: 12) {
                            ForEach(AfterSalesStage.allCases, id: \.self) { stage in
                                HStack(spacing: 12) {
                                    Image(systemName: stage == ticket.stage ? "clock.fill" : "checkmark.circle.fill")
                                        .foregroundStyle(stage == ticket.stage ? AppColors.gold : AppColors.success)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(stage.rawValue)
                                            .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text(stage == ticket.stage ? "Current stage" : "Logged in immutable ticket timeline")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
