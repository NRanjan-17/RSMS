//
//  ReturnsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ReturnsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedResolution: ReturnResolution = .exchange
    @State private var cases: [ReturnCase] = [
        ReturnCase(receipt: "RSMS-2026-0418", client: "Rahul Bajaj", item: "Bottega Veneta The Jodie", amount: "\(CurrencyManager.shared.symbol)2,45,000", resolution: .exchange),
        ReturnCase(receipt: "RSMS-2026-0392", client: "Ananya Kapoor", item: "Cartier Love Bracelet", amount: "\(CurrencyManager.shared.symbol)5,80,000", resolution: .refund)
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
                    Text("Returns & Exchanges")
                        .font(AppFonts.serif(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("NEW CASE")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Receipt RSMS-2026-0418")
                                .font(AppFonts.serif(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Bottega Veneta The Jodie · Rahul Bajaj · Within exchange window")
                                .font(AppFonts.sansSerif(size: 12))
                                .foregroundStyle(AppColors.secondary)
                            
                            Picker("Resolution", selection: $selectedResolution) {
                                ForEach(ReturnResolution.allCases, id: \.self) { resolution in
                                    Text(resolution.rawValue).tag(resolution)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            HStack(spacing: 10) {
                                StatusBadge(text: "Receipt Valid", status: .success)
                                StatusBadge(text: "Manager Refund Check", status: selectedResolution == .refund ? .pending : .neutral)
                            }
                            
                            CustomButton(title: "Create \(selectedResolution.rawValue) Case", icon: AnyView(Image(systemName: "checkmark.seal")), action: {
                                cases.insert(ReturnCase(receipt: "RSMS-2026-0425", client: "Rahul Bajaj", item: "Rolex Submariner Date", amount: "\(CurrencyManager.shared.symbol)14,50,000", resolution: selectedResolution), at: 0)
                            })
                        }
                        .padding(16)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        
                        Text("RECENT CASES")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.secondary)
                            .kerning(1.5)
                        
                        VStack(spacing: 1) {
                            ForEach(cases) { item in
                                HStack(spacing: 12) {
                                    Image(systemName: item.resolution == .refund ? "indianrupeesign.circle" : "arrow.left.arrow.right.circle")
                                        .foregroundStyle(AppColors.gold)
                                        .frame(width: 32, height: 32)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(item.item)
                                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text("\(item.client) · \(item.receipt)")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(item.amount)
                                            .font(AppFonts.serif(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.gold)
                                        StatusBadge(text: item.resolution.rawValue, status: .pending)
                                    }
                                }
                                .padding(14)
                                .background(AppColors.surface)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
