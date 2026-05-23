//
//  UIModels.swift
//  luxury
//
//  Created by Aditya Chauhan on 20/05/26.
//

import Foundation
import SwiftUI

enum BadgeStatus: Hashable {
    case success
    case warning
    case error
    case neutral
    case pending
    
    var color: Color {
        switch self {
        case .success: return AppColors.success
        case .warning: return AppColors.warning
        case .error: return AppColors.error
        case .neutral: return AppColors.tertiary
        case .pending: return AppColors.blue
        }
    }
}

struct RSMSVarianceItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let expected: Int
    let actual: Int
    let reason: String
    
    init(id: UUID = UUID(), name: String, expected: Int, actual: Int, reason: String) {
        self.id = id
        self.name = name
        self.expected = expected
        self.actual = actual
        self.reason = reason
    }
}

struct RSMSCycleCount: Identifiable, Hashable {
    let id: UUID
    let title: String
    let date: String
    let scope: String
    let status: String
    let badgeStatus: BadgeStatus
    
    init(id: UUID = UUID(), title: String, date: String, scope: String, status: String, badgeStatus: BadgeStatus) {
        self.id = id
        self.title = title
        self.date = date
        self.scope = scope
        self.status = status
        self.badgeStatus = badgeStatus
    }
}

struct InventoryAlert: Identifiable, Hashable {
    let id: UUID
    let itemName: String
    let sku: String
    let currentQty: Int
    let status: BadgeStatus
    
    init(id: UUID = UUID(), itemName: String, sku: String, currentQty: Int, status: BadgeStatus) {
        self.id = id
        self.itemName = itemName
        self.sku = sku
        self.currentQty = currentQty
        self.status = status
    }
}

struct StockItem: Identifiable, Hashable {
    let id = UUID()
    let brand: String
    let name: String
    let qty: Int
    let rfid: Bool
    let alert: Bool
}

struct ScannedAuditItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let ok: Bool
}

enum ClientTier: String, CaseIterable, Hashable {
    case standard = "Standard"
    case vip = "VIP"
    case uhnw = "UHNW"
    
    var badgeStatus: BadgeStatus {
        switch self {
        case .standard: return .neutral
        case .vip: return .warning
        case .uhnw: return .success
        }
    }
}

struct Client: Identifiable, Hashable {
    let id: UUID
    let name: String
    let tier: ClientTier
    let lastVisit: String
    let ltv: String
    let initial: String
    let isHot: Bool
    let phone: String?
    let email: String?
    
    // Stable Mock IDs
    static let mockRahulId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let mockPriyaId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let mockDeepaId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let mockAnanyaId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let mockVikramId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let mockRohitId = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!
    
    static let mockIds: Set<UUID> = [
        mockRahulId, mockPriyaId, mockDeepaId, mockAnanyaId, mockVikramId, mockRohitId
    ]
    
    init(id: UUID = UUID(), name: String, tier: ClientTier, lastVisit: String, ltv: String, initial: String, isHot: Bool = false, phone: String? = nil, email: String? = nil) {
        self.id = id
        self.name = name
        self.tier = tier
        self.lastVisit = lastVisit
        if let storedLTV = UserDefaults.standard.string(forKey: "luxury_ltv_\(id.uuidString)") {
            self.ltv = storedLTV
        } else {
            self.ltv = ltv
        }
        self.initial = initial
        self.isHot = isHot
        self.phone = phone
        self.email = email
    }
}

extension Client {
    init(entity: ClientEntity) {
        self.id = entity.id
        self.name = entity.name
        
        let clientTier = ClientTier(rawValue: entity.tier ?? "Standard") ?? .standard
        self.tier = clientTier
        
        let hasPurchases = !(entity.productsPurchased?.isEmpty ?? true)
        self.lastVisit = hasPurchases ? "Today" : "New Client"
        
        // Tier-based default LTV for premium look, but only if they have purchases
        if let storedLTV = UserDefaults.standard.string(forKey: "luxury_ltv_\(entity.id.uuidString)") {
            self.ltv = storedLTV
        } else if hasPurchases {
            switch clientTier {
            case .standard:
                self.ltv = "₹4,50,000"
            case .vip:
                self.ltv = "₹28,00,000"
            case .uhnw:
                self.ltv = "₹1,15,00,000"
            }
        } else {
            self.ltv = "₹0"
        }
        
        let parts = entity.name.components(separatedBy: " ")
        let firstInit = parts.first?.prefix(1) ?? ""
        let lastInit = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        self.initial = "\(firstInit)\(lastInit)".uppercased()
        
        self.isHot = (clientTier == .uhnw && hasPurchases)
        self.phone = entity.phone
        self.email = entity.email
    }
}

struct ClientNote: Identifiable, Hashable {
    let id: UUID = UUID()
    let note: String
    let date: String
    let author: String
}

struct ClientPurchase: Identifiable, Hashable, Codable {
    var id: UUID
    let name: String
    let price: String
    let date: String
    
    init(id: UUID = UUID(), name: String, price: String, date: String) {
        self.id = id
        self.name = name
        self.price = price
        self.date = date
    }
}

struct ClientSizePreference: Identifiable, Hashable, Codable {
    var id: UUID
    var ringSize: String
    var wristSize: String
    var apparelSize: String
    var shoeSize: String
    
    init(id: UUID = UUID(), ringSize: String = "", wristSize: String = "", apparelSize: String = "", shoeSize: String = "") {
        self.id = id
        self.ringSize = ringSize
        self.wristSize = wristSize
        self.apparelSize = apparelSize
        self.shoeSize = shoeSize
    }
}

struct ClientWishlistItem: Identifiable, Hashable, Codable {
    var id: UUID
    let brand: String
    let name: String
    let price: String
    
    init(id: UUID = UUID(), brand: String, name: String, price: String) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
    }
}

struct ClientTicket: Identifiable, Hashable {
    let id: UUID = UUID()
    let title: String
    let status: String
    let date: String
    let isActive: Bool
}

struct ClientStat: Identifiable, Hashable {
    let id = UUID()
    let value: String
    let label: String
}

struct ApprovalRequest: Identifiable, Hashable {
    let id: UUID
    let associateName: String
    let clientName: String
    let amount: String
    let discount: String
    
    init(id: UUID = UUID(), associateName: String, clientName: String, amount: String, discount: String) {
        self.id = id
        self.associateName = associateName
        self.clientName = clientName
        self.amount = amount
        self.discount = discount
    }
}

struct BMAppointment: Identifiable, Hashable {
    let id: UUID
    let clientName: String
    let time: String
    let advisorName: String
    let type: String
    
    init(id: UUID = UUID(), clientName: String, time: String, advisorName: String, type: String) {
        self.id = id
        self.clientName = clientName
        self.time = time
        self.advisorName = advisorName
        self.type = type
    }
}

struct SAAppointment: Identifiable, Hashable {
    var id = UUID()
    let time: String
    let name: String
    let tier: String?
    let type: String
    let initial: String
    let done: Bool
    
    init(id: UUID = UUID(), time: String, name: String, tier: String?, type: String, initial: String, done: Bool) {
        self.id = id
        self.time = time
        self.name = name
        self.tier = tier
        self.type = type
        self.initial = initial
        self.done = done
    }
}

struct SADashAppointment: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let name: String
    let tier: String
    let type: String
    let initial: String
}

struct SADashClient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let tier: String
    let lastVisit: String
    let ltv: String
    let initial: String
}

struct Product: Identifiable, Hashable {
    let id: UUID
    let brand: String
    let name: String
    let price: String
    let inStock: Bool
    
    init(id: UUID = UUID(), brand: String, name: String, price: String, inStock: Bool) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.inStock = inStock
    }
}

struct CartItemModel: Identifiable, Hashable {
    let id: UUID
    let brand: String
    let name: String
    let price: Int
    var qty: Int
    
    init(id: UUID = UUID(), brand: String, name: String, price: Int, qty: Int) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.qty = qty
    }
}

enum TenderMode: String, CaseIterable, Hashable {
    case card = "Card"
    case upi = "UPI"
    case split = "Split"
    case cash = "Cash"
}

struct ScanSession: Identifiable, Hashable {
    let id: UUID
    let date: String
    let zone: String
    let scannedCount: Int
    let expectedCount: Int
    let variance: Int
    
    init(id: UUID = UUID(), date: String, zone: String, scannedCount: Int, expectedCount: Int, variance: Int) {
        self.id = id
        self.date = date
        self.zone = zone
        self.scannedCount = scannedCount
        self.expectedCount = expectedCount
        self.variance = variance
    }
}

struct RFIDTag: Identifiable, Hashable, Codable {
    let id: UUID
    let epc: String
    let name: String
    let ok: Bool
    
    init(id: UUID = UUID(), epc: String, name: String, ok: Bool) {
        self.id = id
        self.epc = epc
        self.name = name
        self.ok = ok
    }
}

struct TransferItem: Identifiable, Hashable {
    let id: UUID
    let sku: String
    let name: String
    var qty: Int
    var availableQty: Int
    
    init(id: UUID = UUID(), sku: String, name: String, qty: Int, availableQty: Int = 10) {
        self.id = id
        self.sku = sku
        self.name = name
        self.qty = qty
        self.availableQty = availableQty
    }
}

struct TransferRequest: Identifiable, Hashable {
    let id: UUID
    let reference: String
    let source: String
    let destination: String
    let items: [TransferItem]
    let status: String
    let badgeStatus: BadgeStatus
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.qty }
    }
    
    init(
        id: UUID = UUID(),
        reference: String = "",
        source: String,
        destination: String,
        items: [TransferItem] = [],
        status: String,
        badgeStatus: BadgeStatus = .neutral
    ) {
        self.id = id
        self.reference = reference
        self.source = source
        self.destination = destination
        self.items = items
        self.status = status
        self.badgeStatus = badgeStatus
    }
}

struct StoreEvent: Identifiable, Hashable {
    let id: UUID
    let title: String
    let date: String
    let rsvpCount: Int
    let type: String
    
    init(id: UUID = UUID(), title: String, date: String, rsvpCount: Int, type: String) {
        self.id = id
        self.title = title
        self.date = date
        self.rsvpCount = rsvpCount
        self.type = type
    }
}

struct ReportItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let icon: String
    
    init(id: UUID = UUID(), title: String, subtitle: String, icon: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
}

struct GlobalKPI: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let value: String
    let trend: Double
    let icon: String
}

struct RevenueData: Identifiable, Hashable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct SalesCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let revenue: String
    let percentage: Double
}

struct TierMetric: Identifiable, Hashable {
    let id = UUID()
    let tier: String
    let count: Int
    let revenue: String
}

struct TeamMember: Identifiable, Hashable {
    let id: UUID
    let name: String
    let role: String
    let shift: String
    let status: String
    let badgeStatus: BadgeStatus
    let salesToday: String
    
    init(id: UUID = UUID(), name: String, role: String, shift: String, status: String, badgeStatus: BadgeStatus, salesToday: String) {
        self.id = id
        self.name = name
        self.role = role
        self.shift = shift
        self.status = status
        self.badgeStatus = badgeStatus
        self.salesToday = salesToday
    }
}

struct BMStaffMember: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let rev: String
    let target: String
    let pct: Double
    let initials: String
    let live: Bool
    let clients: Int
    var avatarUrl: String? = nil
    var resumeUrl: String? = nil
}

struct StaffMetric: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let commission: String
    let conversion: String
    let interactions: Int
}

enum MockApprovalState: String, CaseIterable, Hashable {
    case waiting = "Waiting"
    case approved = "Approved"
    case rejected = "Rejected"
    case timedOut = "Timed Out"
}

enum ReturnResolution: String, CaseIterable, Hashable {
    case refund = "Refund"
    case exchange = "Exchange"
    case storeCredit = "Store Credit"
}

enum AfterSalesStage: String, CaseIterable, Hashable {
    case intake = "Intake"
    case inspection = "Inspection"
    case brandReview = "Brand Review"
    case ready = "Ready"
}

struct DiscountRequest: Identifiable, Hashable {
    let id = UUID()
    let client: String
    let total: String
    let discount: String
    let advisor: String
    let time: String
}

struct AfterSalesTicket: Identifiable, Hashable {
    let id = UUID()
    let client: String
    let item: String
    let serial: String
    let issue: String
    let stage: AfterSalesStage
    let photoRequired: Bool
}

struct ReturnCase: Identifiable, Hashable {
    let id = UUID()
    let receipt: String
    let client: String
    let item: String
    let amount: String
    let resolution: ReturnResolution
}

struct CertificateRecord: Identifiable, Hashable {
    let id = UUID()
    let item: String
    let serial: String
    let certificate: String
    let status: String
}
