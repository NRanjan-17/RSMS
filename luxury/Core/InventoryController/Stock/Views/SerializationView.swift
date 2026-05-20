//
//  SerializationView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct SerializationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var serial = "RLX-126610LN-8M2"
    @State private var certificate = "COA-IND-MUM-2048"
    @State private var records: [CertificateRecord] = [
        CertificateRecord(item: "Rolex Submariner Date", serial: "RLX-126610LN-8M2", certificate: "COA-IND-MUM-2048", status: "Linked"),
        CertificateRecord(item: "Hermès Birkin 30", serial: "HRM-B30-4402", certificate: "COA-IND-MUM-2017", status: "Saved")
    ]
    
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
                    Text("Serialization & CoA")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("CAPTURE")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        VStack(spacing: 12) {
                            TextField("Serial number", text: $serial)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            TextField("Certificate number", text: $certificate)
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.text)
                                .padding(14)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            
                            CustomButton(title: "Save Certificate Link", icon: AnyView(Image(systemName: "link")), action: {
                                records.insert(CertificateRecord(item: "Manual SKU Entry", serial: serial, certificate: certificate, status: "Linked"), at: 0)
                            })
                        }
                        
                        Text("RECENT RECORDS")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        VStack(spacing: 1) {
                            ForEach(records) { record in
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.badge.gearshape")
                                        .foregroundStyle(AppColors.gold)
                                        .frame(width: 32, height: 32)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(record.item)
                                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text("\(record.serial) · \(record.certificate)")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    StatusBadge(text: record.status, status: .success)
                                }
                                .padding(14)
                                .background(AppColors.surface)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        HStack(spacing: 12) {
                            CustomOutlineButton(title: "Print", icon: AnyView(Image(systemName: "printer")), action: {})
                            CustomOutlineButton(title: "Save PDF", icon: AnyView(Image(systemName: "square.and.arrow.down")), action: {})
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
