import Foundation

struct AppointmentEntity: Codable, Identifiable, Hashable {
    var id: UUID
    var clientId: UUID?
    var boutiqueId: UUID
    var timestamp: String
    var appointmentType: String
    var assignedTo: UUID?
    var createdBy: UUID
    var status: String
    var createdAt: String?
    
    // Optional client relationship (if we join with client)
    var client: ClientEntity?
    
    var displayAppointmentType: String {
        if let type = AppointmentType(rawValue: appointmentType) {
            return type.displayName
        }
        return appointmentType.capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    var formattedTime: String {
        guard let date = ISO8601DateFormatter().date(from: timestamp) else { return timestamp }
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }
    
    var formattedDate: String {
        guard let date = ISO8601DateFormatter().date(from: timestamp) else { return timestamp }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case clientId = "client_id"
        case boutiqueId = "boutique_id"
        case timestamp = "timestamp"
        case appointmentType = "appointment_type"
        case assignedTo = "assigned_to"
        case createdBy = "created_by"
        case status
        case createdAt = "created_at"
        case client
    }
}

public enum AppointmentType: String, Codable, CaseIterable {
    case inStore = "in_store"
    case online = "online"
    
    public var displayName: String {
        switch self {
        case .inStore: return "In Store"
        case .online: return "Online"
        }
    }
}
