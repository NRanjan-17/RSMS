//
//  TransfersViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class TransfersViewModel {
    var pendingTransfers: [TransferRequest] = [
        TransferRequest(
            reference: "TR-9042",
            source: "Main Boutique",
            destination: "Airport Lounge",
            items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 5),
            status: "Approved",
            badgeStatus: .success
        ),
        TransferRequest(
            reference: "TR-9045",
            source: "DC South",
            destination: "Main Boutique",
            items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 12),
            status: "In Transit",
            badgeStatus: .pending
        ),
        TransferRequest(
            reference: "TR-9048",
            source: "Main Boutique",
            destination: "Repair Center",
            items: Array(repeating: TransferItem(sku: "DUMMY", name: "Dummy Item", qty: 1), count: 2),
            status: "Submitted",
            badgeStatus: .neutral
        )
    ]
}
