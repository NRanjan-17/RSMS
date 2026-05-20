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
    
    var events: [StoreEvent] = [
        StoreEvent(title: "VIP Winter Preview", date: "22 May 2026", rsvpCount: 45, type: "TRUNK SHOW"),
        StoreEvent(title: "Rolex Heritage Launch", date: "05 June 2026", rsvpCount: 120, type: "PRODUCT LAUNCH")
    ]
}
