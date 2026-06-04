import Foundation
import Observation

@Observable
final class AuditViewModel {
    var scheduledCounts: [RSMSCycleCount] = []
    var recentAudits: [RSMSCycleCount] = []
    
    private let profileService = ProfileService()
    private let cycleCountService = CycleCountService()
    
    init() {
        refreshData()
    }
    
    func refreshData() {
        Task {
            do {
                guard let profile = try await profileService.fetchCurrentProfile(),
                      profile.0 == .inventoryController,
                      let staff = profile.1 as? StaffModel,
                      let boutiqueId = staff.boutiqueId else { return }
                
                let audits = try await cycleCountService.fetchAudits(boutiqueId: boutiqueId)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let todayString = dateFormatter.string(from: Date())
                
                var scheduled: [RSMSCycleCount] = []
                var completed: [RSMSCycleCount] = []
                
                for dbAudit in audits {
                    let formattedDate = CycleCountViewModel.shared.getFormattedDate(from: dbAudit.scheduledDate)
                    
                    if dbAudit.status == .signedOff {
                        let count = RSMSCycleCount(
                            id: dbAudit.id,
                            title: "Full Audit",
                            date: formattedDate,
                            scope: "Full Store",
                            status: "SIGNED OFF",
                            badgeStatus: .success
                        )
                        completed.append(count)
                    } else if dbAudit.status == .inProgress {
                        let count = RSMSCycleCount(
                            id: dbAudit.id,
                            title: "Full Audit",
                            date: formattedDate,
                            scope: "Full Store",
                            status: "Submitted",
                            badgeStatus: .success
                        )
                        completed.append(count)
                    } else {
                        var statusStr = "UPCOMING"
                        var badge: BadgeStatus = .neutral
                        
                        if dbAudit.scheduledDate < todayString {
                            statusStr = "PENDING"
                            badge = .error
                        } else if dbAudit.scheduledDate == todayString {
                            statusStr = "DUE"
                            badge = .warning
                        }
                        
                        let count = RSMSCycleCount(
                            id: dbAudit.id,
                            title: "Full Audit",
                            date: formattedDate,
                            scope: "Full Store",
                            status: statusStr,
                            badgeStatus: badge
                        )
                        scheduled.append(count)
                    }
                }
                
                await MainActor.run {
                    self.scheduledCounts = scheduled
                    self.recentAudits = completed
                }
            } catch {
                print("Failed to fetch audits: \(error)")
            }
        }
    }
}
