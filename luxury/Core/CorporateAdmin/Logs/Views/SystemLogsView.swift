//
//  SystemLogsView.swift
//  luxury
//
//  Created by Aditya Chauhan on 18/05/26.
//

import SwiftUI

struct SystemLogsView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = SystemLogsViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomHeader(title: "System Logs")
                
                VStack(spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "All", isSelected: viewModel.selectedCategory == nil) {
                                withAnimation { viewModel.selectedCategory = nil }
                            }
                            
                            ForEach(LogCategory.allCases, id: \.self) { category in
                                FilterChip(label: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                                    withAnimation { viewModel.selectedCategory = category }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView().tint(AppColors.gold)
                        Spacer()
                    } else if let error = viewModel.errorMessage {
                        Spacer()
                        Text(error).font(AppFonts.sansSerif(size: 14)).foregroundStyle(AppColors.error).padding(40)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                ForEach(viewModel.filteredLogs) { log in
                                    LogRow(log: log)
                                    if log.id != viewModel.filteredLogs.last?.id {
                                        Divider().background(AppColors.gold15).padding(.leading, 64)
                                    }
                                }
                            }
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                            
                            CustomButton(
                                title: "Logout",
                                icon: AnyView(Image(systemName: "rectangle.portrait.and.arrow.right").font(.system(size: 14, weight: .semibold))),
                                action: {
                                    coordinator.logout()
                                }
                            )
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 40)
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(AppFonts.sansSerif(size: 11, weight: isSelected ? .medium : .light))
                .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppColors.gold : Color.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5)
                )
        }
    }
}

private struct LogRow: View {
    let log: SystemLogEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(severityColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: categoryIcon)
                    .font(.system(size: 14))
                    .foregroundStyle(severityColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(log.category.rawValue.uppercased())
                        .font(AppFonts.sansSerif(size: 9, weight: .bold))
                        .foregroundStyle(severityColor)
                        .kerning(1)
                    Spacer()
                    Text(timeString)
                        .font(AppFonts.sansSerif(size: 10))
                        .foregroundStyle(AppColors.tertiary)
                }
                
                Text(log.message)
                    .font(AppFonts.sansSerif(size: 13, weight: .light))
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                
                if let boutique = log.boutiqueName {
                    Text(boutique)
                        .font(AppFonts.sansSerif(size: 11))
                        .foregroundStyle(AppColors.gold)
                        .padding(.top, 2)
                }
            }
        }
        .padding(16)
    }
    
    private var severityColor: Color {
        switch log.severity {
        case .critical: return AppColors.error
        case .warning: return AppColors.warning
        case .info: return AppColors.gold
        }
    }
    
    private var categoryIcon: String {
        switch log.category {
        case .security: return "shield.fill"
        case .inventory: return "box.truck.fill"
        case .access: return "key.fill"
        case .system: return "gearshape.fill"
        }
    }
    
    private var timeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: log.timestamp, relativeTo: Date())
    }
}
