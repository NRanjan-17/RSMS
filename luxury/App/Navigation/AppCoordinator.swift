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
    let routingService = RoutingService()
    
    var rootDestination: RoutingService.Destination {
        routingService.currentDestination
    }
    
    func logout() {
        Task {
            routingService.intendedRole = nil
            try? await AuthService().signOut()
        }
    }
}
