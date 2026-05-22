//
//  DashboardViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation
import Network

enum PacingStatus: String {
    case exceeded = "Target Achieved"
    case ahead    = "Ahead of Pace"
    case onTrack  = "On Track"
    case behind   = "Behind Pace"

    var badgeStatus: BadgeStatus {
        switch self {
        case .exceeded: return .success
        case .ahead:    return .success
        case .onTrack:  return .warning
        case .behind:   return .error
        }
    }
}

@Observable
final class DashboardViewModel {

    private var salesActualRaw: Double = 1_245_000
    private let salesTargetRaw: Double = 1_500_000
    private let storeOpenHour:  Double = 10
    private let storeCloseHour: Double = 20
    private var updateTask:  Task<Void, Never>?
    private var monitorTask: Task<Void, Never>?

    var isTargetConfigured: Bool = true
    var isOffline:          Bool = false
    var lastSyncedAt:       Date = Date()

    var todaySales:  String { isTargetConfigured ? formatINR(salesActualRaw) : "—" }
    var salesTarget: String { isTargetConfigured ? formatINR(salesTargetRaw) : "No target set" }

    var salesProgress: Double {
        guard isTargetConfigured, salesTargetRaw > 0 else { return 0 }
        return salesActualRaw / salesTargetRaw
    }

    var pacingProgress: Double {
        let c   = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let now = Double(c.hour ?? Int(storeOpenHour)) + Double(c.minute ?? 0) / 60.0
        return min(1.0, max(0, now - storeOpenHour) / (storeCloseHour - storeOpenHour))
    }

    var pacingStatus: PacingStatus {
        guard isTargetConfigured else { return .onTrack }
        if salesProgress >= 1.0   { return .exceeded }
        let d = salesProgress - pacingProgress
        if d >  0.05 { return .ahead  }
        if d < -0.05 { return .behind }
        return .onTrack
    }

    var projectedSales: String {
        guard isTargetConfigured, pacingProgress > 0.01 else { return salesTarget }
        return formatINR(salesActualRaw / pacingProgress)
    }

    var lastSyncedText: String {
        let f        = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: lastSyncedAt, relativeTo: Date())
    }

    var pendingApprovals: [ApprovalRequest] = [
        ApprovalRequest(associateName: "Aman Gupta", clientName: "Vikram Seth", amount: "₹4,50,000", discount: "15%"),
        ApprovalRequest(associateName: "Priya R.",   clientName: "Ananya M.",   amount: "₹1,20,000", discount: "12%")
    ]

    var appointments: [BMAppointment] = [
        BMAppointment(clientName: "Siddharth K.",  time: "11:30 AM", advisorName: "Aman Gupta", type: "In-Store"),
        BMAppointment(clientName: "Meera J.",      time: "02:00 PM", advisorName: "Priya R.",   type: "Video Consult"),
        BMAppointment(clientName: "Rajesh Khanna", time: "04:30 PM", advisorName: "Suresh V.",  type: "VIP Preview")
    ]

    func startRealTimeUpdates() {
        startSalesPolling()
        startNetworkMonitoring()
    }

    func stopRealTimeUpdates() {
        updateTask?.cancel()
        updateTask = nil
        monitorTask?.cancel()
        monitorTask = nil
    }

    func approve(_ request: ApprovalRequest) {
        pendingApprovals.removeAll { $0.id == request.id }
    }

    func reject(_ request: ApprovalRequest) {
        pendingApprovals.removeAll { $0.id == request.id }
    }

    private func startSalesPolling() {
        updateTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                self?.fetchLatestSales()
            }
        }
    }

    private func startNetworkMonitoring() {
        monitorTask = Task { @MainActor [weak self] in
            for await offline in Self.networkStatusStream() {
                guard !Task.isCancelled else { return }
                self?.isOffline = offline
                if !offline { self?.lastSyncedAt = Date() }
            }
        }
    }

    private static func networkStatusStream() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status != .satisfied)
            }
            monitor.start(queue: .global())
            continuation.onTermination = { _ in monitor.cancel() }
        }
    }

    private func fetchLatestSales() {
        salesActualRaw += Double.random(in: 5_000...20_000)
        lastSyncedAt    = Date()
    }

    private func formatINR(_ value: Double) -> String {
        let f                   = NumberFormatter()
        f.numberStyle           = .currency
        f.currencySymbol        = "₹"
        f.maximumFractionDigits = 0
        f.locale                = Locale(identifier: "en_IN")
        return f.string(from: NSNumber(value: value)) ?? "₹0"
    }
}
