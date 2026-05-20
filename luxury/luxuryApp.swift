//
//  luxuryApp.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

@main
struct luxuryApp: App {
    @State private var appCoordinator = AppCoordinator()
    @State private var saAppState = SalesAssociateAppState()
    @State private var bmAppState = BoutiqueManagerAppState()
    @State private var icAppState = InventoryControllerAppState()
    @State private var caAppState = CorporateAdminAppState()
    
    init() {
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(AppColors.background)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.gold)
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(AppColors.background)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        UIScrollView.appearance().showsVerticalScrollIndicator = false
        UIScrollView.appearance().showsHorizontalScrollIndicator = false
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appCoordinator)
                .environment(saAppState)
                .environment(bmAppState)
                .environment(icAppState)
                .environment(caAppState)
                .preferredColorScheme(.dark)
        }
    }
}

