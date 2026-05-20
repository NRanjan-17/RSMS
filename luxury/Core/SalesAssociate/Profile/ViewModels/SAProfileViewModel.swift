//
//  SAProfileViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class SAProfileViewModel {
    var store: String = "Maison Mumbai"
    var greeting: String = "Good morning,"
    var name: String = "Arjun Singh."
    
    var revenue: String = "₹2,45,000"
    var target: String = "of ₹4,00,000 target"
    var progress: Double = 0.61
    
    var statClients: String = "4"
    var statTransactions: String = "6"
    var statAppts: String = "3"
    
    var appointments: [SADashAppointment] = [
        SADashAppointment(time: "2:30 PM", name: "Riya Kapoor", tier: "VIP", type: "Watch Consultation", initial: "RK"),
        SADashAppointment(time: "4:00 PM", name: "James Chen", tier: "UHNW", type: "Fall Collection Preview", initial: "JC")
    ]
    
    var recentClients: [SADashClient] = [
        SADashClient(name: "Priya Mehta", tier: "VIP", lastVisit: "2 days ago", ltv: "₹85,000", initial: "PM"),
        SADashClient(name: "Sameer Jain", tier: "Standard", lastVisit: "1 week ago", ltv: "₹2,40,000", initial: "SJ")
    ]
}
