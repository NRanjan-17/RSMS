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
    var pendingTransfersCount: Int = 0
    var pendingCycleCountsCount: Int = 1
    
    var events: [StoreEvent] = []
    
    private let localEventsKey = "luxury_local_events"
    
    init() {
        loadLocalEvents()
        fetchPendingTransfersCount()
    }
    
    func fetchPendingTransfersCount() {
        let transfers = TransferPersistence.shared.loadTransfers()
        self.pendingTransfersCount = transfers.filter { 
            $0.status.lowercased() == "submitted" || $0.status.lowercased() == "pending approval"
        }.count
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
        
        // No local events found
        self.events = []
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
