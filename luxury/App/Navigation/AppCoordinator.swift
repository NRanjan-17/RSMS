//
//  AppCoordinator.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    static let shared = AppCoordinator()
    let routingService = RoutingService()
    
    var rootDestination: RoutingService.Destination {
        routingService.currentDestination
    }
    
    func logout() {
        Task {
            try? await AuthService().signOut()
        }
    }
}
