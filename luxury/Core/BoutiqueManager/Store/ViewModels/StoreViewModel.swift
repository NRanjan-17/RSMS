//
//  StoreViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class StoreViewModel {
    var pendingTransfersCount: Int = 3
    var pendingCycleCountsCount: Int = 1
    
    var events: [StoreEvent] = []
    
    private let localEventsKey = "luxury_local_events"
    
    init() {
        loadLocalEvents()
    }
    
    func loadLocalEvents() {
        if let data = UserDefaults.standard.data(forKey: localEventsKey) {
            do {
                let decoded = try JSONDecoder().decode([StoreEvent].self, from: data)
                if !decoded.isEmpty {
                    self.events = decoded
                    return
                }
            } catch {
                print("Failed to decode local events: \(error)")
            }
        }
        
        // If empty, generate defaults
        let mockRahulId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        let mockPriyaId = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        let mockDeepaId = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        let mockAnanyaId = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        let mockVikramId = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
        
        let defaultGuests = [
            VIPGuest(id: mockRahulId, name: "Rahul Bajaj", tier: "UHNW", status: "Confirmed", reminderSent: false),
            VIPGuest(id: mockPriyaId, name: "Priya Shah", tier: "UHNW", status: "No Response", reminderSent: false),
            VIPGuest(id: mockDeepaId, name: "Deepa Srinivas", tier: "VIP", status: "Confirmed", reminderSent: false),
            VIPGuest(id: mockAnanyaId, name: "Ananya Kapoor", tier: "VIP", status: "No Response", reminderSent: false),
            VIPGuest(id: mockVikramId, name: "Vikram Nair", tier: "VIP", status: "Declined", reminderSent: false)
        ]
        
        // Default deadline: 2 days from now (approaching soon)
        let deadlineDate = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        
        self.events = [
            StoreEvent(
                title: "VIP Winter Preview",
                date: "30 May 2026",
                rsvpCount: 2,
                type: "VIP PREVIEW",
                featuredCollection: "Winter High Jewelry Collection",
                venue: "VIP Salon",
                hostAssociate: "Sarah Connor",
                guests: defaultGuests,
                deadline: deadlineDate,
                reminderWindowHours: 48,
                remindersSent: false
            ),
            StoreEvent(
                title: "Rolex Heritage Launch",
                date: "05 June 2026",
                rsvpCount: 2,
                type: "PRODUCT LAUNCH",
                featuredCollection: "Rolex Heritage Chronograph Collection",
                venue: "Main Showroom",
                hostAssociate: "Sarah Connor",
                guests: defaultGuests,
                deadline: deadlineDate,
                reminderWindowHours: 24,
                remindersSent: false
            ),
            StoreEvent(
                title: "Chanel Cruise Trunk Show",
                date: "12 June 2026",
                rsvpCount: 2,
                type: "TRUNK SHOW",
                featuredCollection: "Chanel Cruise Collection",
                venue: "Garden Terrace",
                hostAssociate: "Sarah Connor",
                guests: defaultGuests,
                deadline: deadlineDate,
                reminderWindowHours: 24,
                remindersSent: false
            )
        ]
        saveLocalEvents()
    }
    
    func saveLocalEvents() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: localEventsKey)
        } catch {
            print("Failed to encode local events: \(error)")
        }
    }
    
    func addEvent(_ event: StoreEvent) {
        events.append(event)
        saveLocalEvents()
    }
    
    func updateEvent(_ event: StoreEvent) {
        if let idx = events.firstIndex(where: { $0.id == event.id }) {
            events[idx] = event
            saveLocalEvents()
        }
    }
    
    func deleteEvent(id: UUID) {
        events.removeAll(where: { $0.id == id })
        saveLocalEvents()
    }
}
