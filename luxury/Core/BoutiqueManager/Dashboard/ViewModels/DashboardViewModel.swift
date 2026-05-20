//
//  DashboardViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    var todaySales: String = "₹12,45,000"
    var salesTarget: String = "₹15,00,000"
    var salesProgress: Double = 0.83
    
    var pendingApprovals: [ApprovalRequest] = [
        ApprovalRequest(associateName: "Aman Gupta", clientName: "Vikram Seth", amount: "₹4,50,000", discount: "15%"),
        ApprovalRequest(associateName: "Priya R.", clientName: "Ananya M.", amount: "₹1,20,000", discount: "12%")
    ]
    
    var appointments: [BMAppointment] = [
        BMAppointment(clientName: "Siddharth K.", time: "11:30 AM", advisorName: "Aman Gupta", type: "In-Store"),
        BMAppointment(clientName: "Meera J.", time: "02:00 PM", advisorName: "Priya R.", type: "Video Consult"),
        BMAppointment(clientName: "Rajesh Khanna", time: "04:30 PM", advisorName: "Suresh V.", type: "VIP Preview")
    ]
    
    func approve(_ request: ApprovalRequest) {
        pendingApprovals.removeAll { $0.id == request.id }
    }
    
    func reject(_ request: ApprovalRequest) {
        pendingApprovals.removeAll { $0.id == request.id }
    }
}
