//
//  AppointmentsViewModel.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import Foundation
import Observation

@Observable
final class AppointmentsViewModel {
    var appointments: [SAAppointment] = [
        SAAppointment(time: "10:00 AM", name: "Rahul Bajaj", tier: "UHNW", type: "Watch Collection Preview", initial: "RB", done: true),
        SAAppointment(time: "2:30 PM", name: "Ananya Kapoor", tier: "VIP", type: "Fall Collection Walkthrough", initial: "AK", done: false),
        SAAppointment(time: "6:00 PM", name: "Walk-in Client", tier: nil, type: "Private Fitting", initial: "?", done: false)
    ]
    
    var currentMonthDays: [(Int, String, String)] = {
        let calendar = Calendar.current
        let today = Date()
        let range = calendar.range(of: .day, in: .month, for: today)!
        let month = calendar.component(.month, from: today)
        let year = calendar.component(.year, from: today)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        return range.map { day -> (Int, String, String) in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            let date = calendar.date(from: components)!
            let weekdayStr = formatter.string(from: date)
            return (day, weekdayStr, "\(day)")
        }
    }()
    
    var remainingCount: Int {
        appointments.filter { !$0.done }.count
    }
}
