//
//  SAProfileViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

struct SAShift: Identifiable {
    let id = UUID()
    let date: String
    let time: String
    let location: String
}

@Observable
final class SAProfileViewModel {
    var store: String = ""
    var greeting: String = ""
    var name: String = ""
    var employeeId: String = ""
    var role: String = ""
    
    var personalSales: String = ""
    var salesGoal: String = ""
    var progress: Double = 0.0
    var commissions: String = ""
    
    var statClients: String = ""
    var statTransactions: String = ""
    var statAppts: String = ""
    
    var upcomingShifts: [SAShift] = []
    
    var isLoading: Bool = false
    
    @MainActor
    func loadProfileData() async {
        isLoading = true
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        self.store = "Maison Mumbai"
        self.greeting = "Good morning,"
        self.name = "Arjun Singh"
        self.employeeId = "CA-8472"
        self.role = "Senior Client Advisor"
        
        self.personalSales = "\(CurrencyManager.shared.symbol)1,20,000"
        self.salesGoal = "of \(CurrencyManager.shared.symbol)2,00,000 target"
        self.progress = 0.60
        self.commissions = "\(CurrencyManager.shared.symbol)12,000"
        
        self.statClients = "4"
        self.statTransactions = "6"
        self.statAppts = "3"
        
        self.upcomingShifts = [
            SAShift(date: "Today, 13 May", time: "10:00 AM - 7:00 PM", location: "Main Floor"),
            SAShift(date: "Tomorrow, 14 May", time: "12:00 PM - 9:00 PM", location: "VIP Salon")
        ]
        
        isLoading = false
    }
}
