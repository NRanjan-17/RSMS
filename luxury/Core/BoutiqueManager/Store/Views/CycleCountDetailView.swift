//
//  CycleCountDetailView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import Observation
import Supabase

// MARK: - Models

enum AuditModelStatus: String, Codable {
    case scheduled = "scheduled"
    case due = "due"
    case inProgress = "in_progress"
    case signedOff = "signed_off"
}

struct DiscrepancyItem: Codable, Hashable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let detail: String
    let type: String // "missing" or "new"
}

struct DBStoreAudit: Codable, Identifiable {
    let id: UUID
    let boutiqueId: UUID
    let scheduledDate: String // Stored as "YYYY-MM-DD"
    let fixedDay: Int
    var status: AuditModelStatus
    let totalExpected: Int
    let totalScanned: Int
    let variance: Int
    let accuracy: Double
    let scannedUnitIds: [UUID]?
    let discrepancies: [DiscrepancyItem]?
    var signedOffBy: UUID?
    var signedOffAt: Date?
    let createdBy: UUID?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case boutiqueId = "boutique_id"
        case scheduledDate = "scheduled_date"
        case fixedDay = "fixed_day"
        case status
        case totalExpected = "total_expected"
        case totalScanned = "total_scanned"
        case variance
        case accuracy
        case scannedUnitIds = "scanned_unit_ids"
        case discrepancies
        case signedOffBy = "signed_off_by"
        case signedOffAt = "signed_off_at"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Services

final class CycleCountService {
    private let client = SupabaseManager.shared.client
    
    func fetchAudits(boutiqueId: UUID) async throws -> [DBStoreAudit] {
        return try await client.from("audits")
            .select()
            .eq("boutique_id", value: boutiqueId)
            .order("scheduled_date", ascending: false)
            .execute()
            .value
    }
    
    func signOffAudit(auditId: UUID, userId: UUID) async throws {
        struct UpdatePayload: Codable {
            let status: String
            let signed_off_by: UUID
            let signed_off_at: String
        }
        
        let payload = UpdatePayload(
            status: AuditModelStatus.signedOff.rawValue,
            signed_off_by: userId,
            signed_off_at: ISO8601DateFormatter().string(from: Date())
        )
        
        try await client.from("audits")
            .update(payload)
            .eq("id", value: auditId)
            .execute()
    }
    
    func updateFixedDay(boutiqueId: UUID, day: Int) async throws {
        let activeAudits: [DBStoreAudit] = try await client.from("audits")
            .select()
            .eq("boutique_id", value: boutiqueId)
            .neq("status", value: AuditModelStatus.signedOff.rawValue)
            .order("scheduled_date", ascending: false)
            .limit(1)
            .execute()
            .value
        
        let today = Date()
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month], from: today)
        comps.day = day
        
        var targetDate = calendar.date(from: comps) ?? today
        
        let targetStartOfDay = calendar.startOfDay(for: targetDate)
        let todayStartOfDay = calendar.startOfDay(for: today)
        
        if targetStartOfDay < todayStartOfDay {
            comps.month = (comps.month ?? 0) + 1
            if let newMonthDate = calendar.date(from: comps), 
               let range = calendar.range(of: .day, in: .month, for: newMonthDate) {
                comps.day = min(day, range.count)
            }
            targetDate = calendar.date(from: comps) ?? today
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let scheduledDateStr = dateFormatter.string(from: targetDate)
        
        if let latest = activeAudits.first {
            struct UpdatePayload: Codable {
                let fixed_day: Int
                let scheduled_date: String
            }
            try await client.from("audits")
                .update(UpdatePayload(fixed_day: day, scheduled_date: scheduledDateStr))
                .eq("id", value: latest.id)
                .execute()
        } else {
            struct InsertAudit: Codable {
                let boutique_id: UUID
                let scheduled_date: String
                let fixed_day: Int
                let status: String
            }
            let payload = InsertAudit(
                boutique_id: boutiqueId,
                scheduled_date: scheduledDateStr,
                fixed_day: day,
                status: AuditModelStatus.scheduled.rawValue
            )
            try await client.from("audits")
                .insert(payload)
                .execute()
        }
    }
}

// MARK: - ViewModels

@Observable
final class CycleCountViewModel {
    static let shared = CycleCountViewModel()
    
    var activeAudits: [DBStoreAudit] = []
    var completedAudits: [DBStoreAudit] = []
    
    var openCount: Int { activeAudits.count }
    var closedCount: Int { completedAudits.count }
    
    var isLoading = false
    var errorMessage: String?
    
    var boutiqueId: UUID?
    var currentUserId: UUID?
    
    private let service = CycleCountService()
    private let profileService = ProfileService()
    
    func loadAudits() {
        isLoading = true
        Task {
            do {
                if boutiqueId == nil {
                    let profile = try await profileService.fetchCurrentProfile()
                    if let manager = profile?.1 as? CorporateBoutique {
                        self.boutiqueId = manager.id
                    }
                    if let session = try? await SupabaseManager.shared.client.auth.session {
                        self.currentUserId = session.user.id
                    }
                }
                
                guard let bId = boutiqueId else {
                    await MainActor.run { isLoading = false }
                    return
                }
                
                let audits = try await service.fetchAudits(boutiqueId: bId)
                
                await MainActor.run {
                    self.activeAudits = audits.filter { $0.status != .signedOff }
                    self.completedAudits = audits.filter { $0.status == .signedOff }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOffAudit(auditId: UUID, onSuccess: @escaping () -> Void) {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await service.signOffAudit(auditId: auditId, userId: userId)
                await MainActor.run {
                    self.loadAudits()
                    onSuccess()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func updateFixedDay(day: Int) {
        guard let bId = boutiqueId else { return }
        Task {
            do {
                try await service.updateFixedDay(boutiqueId: bId, day: day)
                await MainActor.run {
                    self.loadAudits()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func getFormattedDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
        return dateString
    }
    
    func getStatusLabel(for status: AuditModelStatus) -> String {
        switch status {
        case .scheduled: return "Scheduled"
        case .due: return "Due"
        case .inProgress: return "In Progress"
        case .signedOff: return "Completed"
        }
    }
    
    func getStatusColor(for status: AuditModelStatus) -> Color {
        switch status {
        case .scheduled: return AppColors.blue
        case .due: return AppColors.warning
        case .inProgress: return AppColors.gold
        case .signedOff: return AppColors.success
        }
    }
}


struct CycleCountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @State private var viewModel = CycleCountViewModel.shared
    @State private var selectedDay: String = ""
    @State private var applyNextMonth: Bool = false
    @State private var showConfirmAlert: Bool = false
    @State private var pendingSelectedDay: String = ""

    private var auditDateTitle: String {
        if selectedDay.isEmpty {
            return "Loading..."
        }
        if selectedDay == "1st Day" {
            return "1st of every month"
        } else if selectedDay == "15th Day" {
            return "15th of every month"
        } else if selectedDay == "Last Day" {
            return "Last day of every month"
        } else {
            return "\(selectedDay) of every month"
        }
    }

    private func formatDayAsOrdinal(_ day: Int) -> String {
        let suffix: String
        if (11...13).contains(day % 100) {
            suffix = "th"
        } else {
            switch day % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(day)\(suffix)"
    }

    private func executeDayUpdate(for dayString: String) {
        var dayNum = 1
        if dayString == "1st Day" { dayNum = 1 }
        else if dayString == "15th Day" { dayNum = 15 }
        else if dayString == "Last Day" { 
            let range = Calendar.current.range(of: .day, in: .month, for: Date())
            dayNum = range?.count ?? 28
        }
        else { dayNum = Int(dayString.replacingOccurrences(of: "st", with: "").replacingOccurrences(of: "nd", with: "").replacingOccurrences(of: "rd", with: "").replacingOccurrences(of: "th", with: "")) ?? 1 }
        
        viewModel.updateFixedDay(day: dayNum)
        
        viewModel.updateFixedDay(day: dayNum)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // 1. Top Section - Summary Metric Cards (First Block)
                        HStack(spacing: 12) {
                            MetricCard(title: "Variance", value: "-1", subtitle: "Net Discrepancy", icon: "arrow.up.arrow.down")
                            MetricCard(title: "Accuracy", value: (0.982).formatted(.percent.precision(.fractionLength(1))), subtitle: "Store Performance", icon: "percent")
                        }
                        .padding(.horizontal, 24)

                        // 2. Middle Section - Tapable Full-Width "Audit Report" Card (Second Block)
                        Button(action: {
                            router.push(BMRoute.auditReportHub)
                        }) {
                            HStack {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColors.gold)
                                    .frame(width: 36, height: 36)
                                    .background(AppColors.gold.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Audit Report")
                                        .font(AppFonts.serif(size: 17, weight: .semibold))
                                        .foregroundStyle(.white)
                                    
                                    Text("\(viewModel.openCount) Active Audits • \(viewModel.closedCount) Archived Records")
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            .padding(16)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }
                        .buttonStyle(PlainButtonStyle())

                        // 3. Lower Section - Simplified Audit Schedule & Date Picker (Third Block)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AUDIT SCHEDULE — MANAGER CONTROL")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("FIXED AUDIT DATE")
                                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                        .foregroundStyle(AppColors.gold)
                                        .kerning(1.0)
                                    
                                    Text(auditDateTitle)
                                        .font(AppFonts.serif(size: 24, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                                
                                // Day Picker Pill Matrix (Simplified)
                                HStack(spacing: 8) {
                                    ForEach(["1st Day", "15th Day", "Last Day"], id: \.self) { day in
                                        Button(action: {
                                            pendingSelectedDay = day
                                            showConfirmAlert = true
                                        }) {
                                            Text(day)
                                                .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(selectedDay == day ? AppColors.gold : AppColors.background)
                                                .foregroundStyle(selectedDay == day ? Color.black : AppColors.text)
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule()
                                                        .stroke(selectedDay == day ? Color.clear : AppColors.border, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(20)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.gold50, lineWidth: 0.8)
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)
                }
            }
            
        }
        .onAppear {
            viewModel.loadAudits()
        }
        .onChange(of: viewModel.isLoading) { _, isLoading in
            if !isLoading {
                if let day = viewModel.activeAudits.first?.fixedDay ?? viewModel.completedAudits.first?.fixedDay {
                    if day == 1 { selectedDay = "1st Day" }
                    else if day == 15 { selectedDay = "15th Day" }
                    else if day == 28 || day == 30 || day == 31 { selectedDay = "Last Day" }
                    else { selectedDay = formatDayAsOrdinal(day) }
                } else {
                    selectedDay = "1st Day"
                }
            }
        }
        .alert("Reschedule Audit", isPresented: $showConfirmAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm") {
                selectedDay = pendingSelectedDay
                executeDayUpdate(for: pendingSelectedDay)
            }
        } message: {
            Text("Are you sure you want to reschedule the monthly audit window?")
        }
        .navigationTitle("Audit Sign-off")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
}

// MARK: - Screen 1: The New Full-Screen Audit Report Hub
struct AuditReportHubView: View {
    @Environment(Router.self) private var router
    @State private var selectedTab: String = "Active"
    @State private var viewModel = CycleCountViewModel.shared
    
    private var activeTabAudits: [DBStoreAudit] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: Date())
        
        return viewModel.activeAudits.filter { audit in
            let isCurrent = (audit.scheduledDate == today) || (audit.status == .inProgress)
            let isPending = (audit.scheduledDate < today) && (audit.status != .signedOff)
            return isCurrent || isPending
        }
    }
    
    private var completedAudits: [DBStoreAudit] {
        viewModel.completedAudits
    }
    
    private func formatDayAsOrdinal(_ day: Int) -> String {
        let suffix: String
        if (11...13).contains(day % 100) { suffix = "th" }
        else {
            switch day % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(day)\(suffix)"
    }
    
    private var upcomingAuditProj: (title: String, dateStr: String, badge: Color)? {
        let fixedDay = viewModel.activeAudits.first?.fixedDay ?? viewModel.completedAudits.first?.fixedDay
        guard let day = fixedDay else { return nil }
        
        let today = Date()
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month], from: today)
        comps.day = day
        
        var projectedDate = calendar.date(from: comps) ?? today
        
        let targetStartOfDay = calendar.startOfDay(for: projectedDate)
        let todayStartOfDay = calendar.startOfDay(for: today)
        
        if targetStartOfDay < todayStartOfDay {
            comps.month = (comps.month ?? 0) + 1
            if let newMonthDate = calendar.date(from: comps), 
               let range = calendar.range(of: .day, in: .month, for: newMonthDate) {
                comps.day = min(day, range.count)
            }
            projectedDate = calendar.date(from: comps) ?? today
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        let formattedDate = formatter.string(from: projectedDate)
        
        return (title: "Audit \(formatDayAsOrdinal(day))", dateStr: formattedDate, badge: AppColors.blue)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Apple Native Segmented Control
                Picker("Tab", selection: $selectedTab) {
                    Text("Active").tag("Active")
                    Text("Upcoming").tag("Upcoming")
                    Text("Completed").tag("Completed")
                }
                .pickerStyle(.segmented)
                .colorScheme(.dark)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Toggle List Views
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        if selectedTab == "Active" {
                            Text("CURRENT OPEN STORE CHECKS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                            
                            VStack(spacing: 12) {
                                ForEach(activeTabAudits) { audit in
                                    ActiveAuditRow(
                                        status: viewModel.getStatusLabel(for: audit.status),
                                        date: viewModel.getFormattedDate(from: audit.scheduledDate),
                                        badgeColor: viewModel.getStatusColor(for: audit.status)
                                    ) {
                                        router.push(BMRoute.activeAuditReportDetail(audit.id.uuidString))
                                    }
                                }
                                if activeTabAudits.isEmpty {
                                    Text("No active or pending audits.")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                        .padding(.vertical, 20)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                        } else if selectedTab == "Upcoming" {
                            Text("PROJECTED SCHEDULE")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                            
                            VStack(spacing: 12) {
                                if let upcoming = upcomingAuditProj {
                                    ActiveAuditRow(
                                        status: "Upcoming",
                                        date: upcoming.dateStr,
                                        badgeColor: upcoming.badge
                                    ) {
                                        // Upcoming view not actionable
                                    }
                                } else {
                                    Text("No schedule configured.")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                        .padding(.vertical, 20)
                                }
                            }
                            .padding(.horizontal, 24)
                            
                        } else {
                            Text("HISTORICAL FINALIZED COUNTS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                            
                            VStack(spacing: 12) {
                                ForEach(completedAudits) { audit in
                                    HubCompletedAuditRow(
                                        date: viewModel.getFormattedDate(from: audit.scheduledDate),
                                        variance: "\(audit.variance)",
                                        accuracy: (audit.accuracy / 100).formatted(.percent.precision(.fractionLength(1)))
                                    ) {
                                        router.push(BMRoute.auditReportDetail(audit.id.uuidString))
                                    }
                                }
                                if completedAudits.isEmpty {
                                    Text("No completed audits yet.")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.secondary)
                                        .padding(.vertical, 20)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Audit History Hub")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
}

// MARK: - Screen 2: Deep Breakdown Sub-View
struct AuditReportDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CycleCountViewModel.shared
    let auditTitle: String // actually auditId.uuidString
    
    private var audit: DBStoreAudit? {
        viewModel.completedAudits.first { $0.id.uuidString == auditTitle } ?? viewModel.activeAudits.first { $0.id.uuidString == auditTitle }
    }
    
    private var missingItems: [DiscrepancyItem] {
        audit?.discrepancies?.filter { $0.type == "missing" } ?? []
    }
    
    private var newItems: [DiscrepancyItem] {
        audit?.discrepancies?.filter { $0.type == "new" } ?? []
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    
                    // Title Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("COUNT HEALTH BREAKDOWN")
                            .font(AppFonts.sansSerif(size: 11, weight: .bold))
                            .foregroundStyle(AppColors.gold)
                            .kerning(1.5)
                        
                        Text(auditTitle)
                            .font(AppFonts.serif(size: 26, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Detailed verification report from store count")
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.secondary)
                    }
                    .padding(.horizontal, 24)
                    
                    // Section A: Missing Items Container
                    if !missingItems.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(AppColors.error)
                                Text("Section A: Missing Items (DB mismatch)")
                                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.error)
                                    .kerning(1.0)
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(missingItems) { item in
                                    BreakdownProductRow(name: item.name, detail: item.detail, status: "Missing", statusColor: AppColors.error)
                                }
                            }
                        }
                    }
                    
                    // Section B: New Items Container
                    if !newItems.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundStyle(AppColors.warning)
                                Text("Section B: Unexpected / New Items")
                                    .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                    .foregroundStyle(AppColors.warning)
                                    .kerning(1.0)
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(newItems) { item in
                                    BreakdownProductRow(name: item.name, detail: item.detail, status: "New Item", statusColor: AppColors.warning)
                                }
                            }
                        }
                    }
                    
                    // Section C: Verified Items Container
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppColors.success)
                            Text("Section C: Verified & Confirmed")
                                .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                .foregroundStyle(AppColors.success)
                                .kerning(1.0)
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            BreakdownProductRow(name: "Golden Ellipse Quartz", detail: "SKU: PP-GE-5738", status: "Verified", statusColor: AppColors.success)
                            BreakdownProductRow(name: "Chronomat Automatic 36", detail: "SKU: BRT-CA-3610", status: "Verified", statusColor: AppColors.success)
                            BreakdownProductRow(name: "Classic Fusion Titanium 45mm", detail: "SKU: HBL-CF-4500", status: "Verified", statusColor: AppColors.success)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Audit Breakdown")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
}

// MARK: - Screen 3: Active Audit Discrepancy & Sign-off View
struct ActiveAuditReportDetailView: View {
    @Environment(Router.self) private var router
    let auditTitle: String // auditId.uuidString
    @State private var viewModel = CycleCountViewModel.shared
    
    private var audit: DBStoreAudit? {
        viewModel.activeAudits.first { $0.id.uuidString == auditTitle }
    }
    
    private var missingItems: [DiscrepancyItem] {
        audit?.discrepancies?.filter { $0.type == "missing" } ?? []
    }
    
    private var newItems: [DiscrepancyItem] {
        audit?.discrepancies?.filter { $0.type == "new" } ?? []
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // Title Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SUBMITTED BY STORE INVENTORY")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                            
                            Text("Review verified anomalies across merged inventory stock before execution.")
                                .font(AppFonts.sansSerif(size: 14))
                                .foregroundStyle(AppColors.secondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 24)
                        
                        // Section A: Missing Items Container
                        if !missingItems.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(AppColors.error)
                                    Text("Section A: Missing Items (DB mismatch)")
                                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.error)
                                        .kerning(1.0)
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(missingItems) { item in
                                        BreakdownProductRow(name: item.name, detail: item.detail, status: "Missing", statusColor: AppColors.error)
                                    }
                                }
                            }
                        }
                        
                        // Section B: New Items Container
                        if !newItems.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundStyle(AppColors.warning)
                                    Text("Section B: Unexpected / New Items")
                                        .font(AppFonts.sansSerif(size: 12, weight: .bold))
                                        .foregroundStyle(AppColors.warning)
                                        .kerning(1.0)
                                }
                                .padding(.horizontal, 24)
                                
                                VStack(spacing: 12) {
                                    ForEach(newItems) { item in
                                        BreakdownProductRow(name: item.name, detail: item.detail, status: "New Item", statusColor: AppColors.warning)
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(.vertical, 24)
                }
                
                // Fixed Sign-off Audit Button at the bottom
                if viewModel.currentUserId != nil {
                    VStack {
                        CustomButton(title: "Sign-off Audit", action: {
                            if let a = audit {
                                viewModel.signOffAudit(auditId: a.id) {
                                    router.pop() // Navigate back on sign-off approval
                                }
                            } else {
                                router.pop()
                            }
                        })
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 34)
                    }
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .overlay(
                        VStack {
                            Divider().background(AppColors.border)
                            Spacer()
                        }
                    )
                }
        }
        .navigationTitle("Active Audit Report")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { router.pop() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                }
            }
        }
    }
}
}

// MARK: - Row Subviews

private struct ActiveAuditRow: View {
    let status: String
    let date: String
    let badgeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date)
                        .font(AppFonts.sansSerif(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                if status.uppercased() != "UPCOMING" {
                    Text(status.uppercased())
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(badgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor.opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(badgeColor.opacity(0.3), lineWidth: 1))
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .padding(.leading, 8)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HubCompletedAuditRow: View {
    let date: String
    let variance: String
    let accuracy: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(date)
                        .font(AppFonts.sansSerif(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Variance")
                                .font(AppFonts.sansSerif(size: 9))
                                .foregroundStyle(AppColors.secondary)
                            Text(variance)
                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                .foregroundStyle(variance.starts(with: "-") ? AppColors.error : (variance == "0" ? AppColors.success : AppColors.warning))
                        }
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Accuracy")
                                .font(AppFonts.sansSerif(size: 9))
                                .foregroundStyle(AppColors.secondary)
                            Text(accuracy)
                                .font(AppFonts.sansSerif(size: 13, weight: .bold))
                                .foregroundStyle(AppColors.success)
                        }
                    }
                    
                    Text("COMPLETED")
                        .font(AppFonts.sansSerif(size: 9, weight: .bold))
                        .foregroundStyle(AppColors.success)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppColors.success.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .padding(.leading, 8)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct BreakdownProductRow: View {
    let name: String
    let detail: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(AppFonts.sansSerif(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text(detail)
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.secondary)
            }
            
            Spacer()
            
            Text(status.uppercased())
                .font(AppFonts.sansSerif(size: 10, weight: .bold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(statusColor.opacity(0.3), lineWidth: 1))
        }
        .padding(16)
        .background(Color(white: 0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border.opacity(0.5), lineWidth: 1))
        .padding(.horizontal, 24)
    }
}

private struct CycleCountVarianceRow: View {
    let item: RSMSVarianceItem

    private var diff: Int {
        item.actual - item.expected
    }

    private var formattedDiff: String {
        "\(diff > 0 ? "+" : "")\(diff)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(item.name)
                    .font(AppFonts.serif(size: 17, weight: .medium))
                    .foregroundStyle(.white)

                Spacer()

                Text(formattedDiff)
                    .font(AppFonts.sansSerif(size: 15, weight: .bold))
                    .foregroundStyle(diff == 0 ? AppColors.success : AppColors.error)
            }

            HStack {
                Text("Exp: \(item.expected)")
                Text("•")
                Text("Act: \(item.actual)")

                Spacer()

                Text(item.reason)
                    .font(AppFonts.sansSerif(size: 11).italic())
                    .foregroundStyle(AppColors.gold70)
            }
            .font(AppFonts.sansSerif(size: 12))
            .foregroundStyle(AppColors.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(AppColors.surface)
    }
}
