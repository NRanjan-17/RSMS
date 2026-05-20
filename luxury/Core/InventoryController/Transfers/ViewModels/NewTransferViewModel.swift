//
//  NewTransferViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class NewTransferViewModel {
    var sourceStore: String = "Main Boutique"
    var destinationStore: String = "Airport Lounge"
    var items: [TransferItem] = [
        TransferItem(sku: "ROL-SUB-126610-LN", name: "Rolex Submariner Date 126610LN", qty: 1),
        TransferItem(sku: "OMG-210.30.42.20.01", name: "Omega Seamaster 210.30.42", qty: 2),
        TransferItem(sku: "AJD-1-HI-OG-CHI-44", name: "Air Jordan 1 High OG Chicago #44", qty: 1)
    ]
    var approvalState: MockApprovalState = .waiting
    var packingSlipGenerated: Bool = false
    
    func submit() {
        approvalState = .waiting
    }
    
    func approve() {
        approvalState = .approved
    }
    
    func completeSession() {
        packingSlipGenerated = true
    }
}
