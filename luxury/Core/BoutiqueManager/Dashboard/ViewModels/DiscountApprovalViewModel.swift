//
//  DiscountApprovalViewModel.swift
//  luxury
//
//  Created by Kaushiki Rai on 22/05/26.
//

import Foundation
import Observation

@Observable
final class DiscountApprovalViewModel {

    var requests: [DiscountRequest] = [
        DiscountRequest(client: "Meera Kapoor",    total: "₹2,45,000", discount: "15%", advisor: "Rahul Sharma",  time: "2 min ago"),
        DiscountRequest(client: "Vikram Malhotra", total: "₹85,000",   discount: "12%", advisor: "Anjali Pathak", time: "10 min ago"),
        DiscountRequest(client: "Sarah John",      total: "₹1,20,000", discount: "20%", advisor: "Rahul Sharma",  time: "15 min ago")
    ]

    func approve(_ request: DiscountRequest) {
        requests.removeAll { $0.id == request.id }
    }

    func reject(_ request: DiscountRequest) {
        requests.removeAll { $0.id == request.id }
    }
}
