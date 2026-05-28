//
//  ClientProfileView.swift
//  luxury
//
//  Created by Aditya Chauhan on 15/05/26.
//

import SwiftUI

struct ClientProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Router.self) private var router
    @State private var viewModel: ClientDetailViewModel
    @State private var showQuickNote = false
    @State private var quickNoteText = ""
    
    init(client: Client = ClientDetailViewModel.defaultClient) {
        _viewModel = State(initialValue: ClientDetailViewModel(client: client))
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(AppFonts.sansSerif(size: 20, weight: .semibold))
                            .foregroundStyle(AppColors.gold)
                    }
                    Text("Clients")
                        .font(AppFonts.sansSerif(size: 13, weight: .medium))
                        .foregroundStyle(AppColors.gold)
                    
                    Spacer()
                    
                    Button("Edit") {
                        router.presentFullScreen(SARoute.editClient(viewModel.client))
                    }
                    .font(AppFonts.sansSerif(size: 13))
                    .foregroundStyle(AppColors.gold)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(spacing: 6) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(AppColors.gold08)
                                    .frame(width: 72, height: 72)
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.gold50, lineWidth: 1))
                                
                                Text(viewModel.client.initial)
                                    .font(AppFonts.serif(size: 26, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding(.bottom, 6)
                            
                            Text(viewModel.client.name)
                                .font(AppFonts.serif(size: 26, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            HStack(spacing: 8) {
                                StatusBadge(text: viewModel.client.tier.rawValue, status: viewModel.client.tier.badgeStatus)
                                Text(viewModel.joinedDateText)
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                        }
                        .padding(.vertical, 18)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.stats.count, id: \.self) { i in
                                VStack(spacing: 3) {
                                    Text(viewModel.stats[i].0)
                                        .font(AppFonts.serif(size: i == 0 ? 13 : 20, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                    Text(viewModel.stats[i].1)
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(AppColors.surface)
                                
                                if i < viewModel.stats.count - 1 {
                                    Rectangle().fill(AppColors.gold15).frame(width: 0.5)
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        .padding(.bottom, 18)
                        
                        HStack(spacing: 0) {
                            ForEach(viewModel.tabs, id: \.0) { tab in
                                let isActive = viewModel.selectedTab == tab.0
                                VStack(spacing: 10) {
                                    Text(tab.1)
                                        .font(AppFonts.sansSerif(size: 12, weight: isActive ? .medium : .light))
                                        .foregroundStyle(isActive ? AppColors.gold : AppColors.secondary)
                                    Rectangle()
                                        .fill(isActive ? AppColors.gold : Color.clear)
                                        .frame(height: 1.5)
                                }
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation { viewModel.selectedTab = tab.0 }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle().fill(AppColors.gold15).frame(height: 0.5)
                            }
                        )
                        .padding(.bottom, 16)
                        
                        HStack(spacing: 10) {
                            CustomOutlineButton(title: "Service Intake", icon: AnyView(Image(systemName: "wrench.and.screwdriver")), action: {
                                router.push(SARoute.afterSalesIntake(client: viewModel.client, serialNumber: nil, isWarrantyActive: true))
                            })
                            
                            CustomOutlineButton(title: "Track Ticket", icon: AnyView(Image(systemName: "clock.badge.checkmark")), action: {
                                router.push(SARoute.afterSalesTracking)
                            })
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                        
                        VStack(spacing: 0) {
                            if viewModel.selectedTab == "overview" {
                                ClientOverviewTab(
                                    viewModel: viewModel,
                                    onApptTap: { router.push(SARoute.appointmentList) },
                                    onNoteTap: { showQuickNote = true },
                                    onTicketTap: { router.push(SARoute.afterSalesTracking) }
                                )
                            } else if viewModel.selectedTab == "history" {
                                ClientHistoryTab(viewModel: viewModel)
                            } else if viewModel.selectedTab == "wishlist" {
                                ClientWishlistTab(viewModel: viewModel)
                            } else if viewModel.selectedTab == "notes" {
                                ClientNotesTab(viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .alert("Quick Note", isPresented: $showQuickNote) {
            TextField("Enter note...", text: $quickNoteText)
            Button("Save") {
                if !quickNoteText.isEmpty {
                    let text = quickNoteText
                    Task {
                        await viewModel.addNote(text: text)
                    }
                    quickNoteText = ""
                }
            }
            Button("Cancel", role: .cancel) {
                quickNoteText = ""
            }
        } message: {
            Text("Add a quick note for \(viewModel.client.name)")
        }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshClients"))) { _ in
            Task {
                do {
                    let updatedEntity = try await ClientService().fetchClient(id: viewModel.client.id)
                    let updatedClient = Client(entity: updatedEntity)
                    await MainActor.run {
                        viewModel.client = updatedClient
                    }
                } catch {
                    print("Error reloading profile details: \(error)")
                }
            }
        }
    }
}

private struct ClientOverviewTab: View {
    let viewModel: ClientDetailViewModel
    var onApptTap: () -> Void
    var onNoteTap: () -> Void
    var onTicketTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 8) {
                QuickActionButton(label: "Note", icon: "square.and.pencil", action: onNoteTap)
            }
            let client = viewModel.client
            let hasAdditionalInfo = (client.dob != nil && !client.dob!.isEmpty) || 
                                    (client.maritalStatus != nil && !client.maritalStatus!.isEmpty) || 
                                    (client.dateOfAnniversary != nil && !client.dateOfAnniversary!.isEmpty)
            
            if hasAdditionalInfo {
                VStack(alignment: .leading, spacing: 12) {
                    Text("ADDITIONAL DETAILS")
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.secondary)
                        .kerning(1.5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        if let dob = client.dob, !dob.isEmpty {
                            HStack {
                                Text("Date of Birth")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(dob)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            if (client.maritalStatus != nil && !client.maritalStatus!.isEmpty) || (client.dateOfAnniversary != nil && !client.dateOfAnniversary!.isEmpty) {
                                Divider().background(AppColors.border)
                            }
                        }
                        
                        if let maritalStatus = client.maritalStatus, !maritalStatus.isEmpty {
                            HStack {
                                Text("Marital Status")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(maritalStatus)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                            if client.dateOfAnniversary != nil && !client.dateOfAnniversary!.isEmpty {
                                Divider().background(AppColors.border)
                            }
                        }
                        
                        if let anniversary = client.dateOfAnniversary, !anniversary.isEmpty {
                            HStack {
                                Text("Anniversary Date")
                                    .font(AppFonts.sansSerif(size: 12))
                                    .foregroundStyle(AppColors.secondary)
                                Spacer()
                                Text(anniversary)
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(16)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Appointment Tracking")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1.5)
                
                if viewModel.tickets.isEmpty {
                    Text("No active service tickets")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                        .padding(.vertical, 4)
                } else {
                    VStack(spacing: 10) {
                        let sortedTickets = viewModel.tickets.sorted { $0.isActive && !$1.isActive }
                        ForEach(sortedTickets) { ticket in
                            Button(action: onTicketTap) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(ticket.isActive ? AppColors.gold : AppColors.tertiary)
                                        .frame(width: 8, height: 8)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(ticket.title)
                                            .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                            .foregroundStyle(.white)
                                        Text("\(ticket.status) · \(ticket.date)")
                                            .font(AppFonts.sansSerif(size: 11))
                                            .foregroundStyle(AppColors.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(AppFonts.sansSerif(size: 12))
                                        .foregroundStyle(AppColors.tertiary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // UPCOMING block removed
            
            if let lastPurchase = viewModel.purchases.first {
                VStack(alignment: .leading, spacing: 12) {
                    Text("LAST PURCHASE")
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.secondary)
                        .kerning(1.5)
                    
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(AppColors.surface2)
                                .frame(width: 42, height: 42)
                            Image(systemName: "circle.grid.cross")
                                .font(AppFonts.sansSerif(size: 16))
                                .foregroundStyle(AppColors.gold)
                                .opacity(0.4)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(lastPurchase.name)
                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                            Text("\(CurrencyManager.shared.format(amount: lastPurchase.price)) · \(lastPurchase.date)")
                                .font(AppFonts.sansSerif(size: 11))
                                .foregroundStyle(AppColors.gold)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                }
            }
            
            // UPCOMING OCCASIONS Section
            let bdayDays = daysToNextOccasion(dateStr: client.dob)
            let isMarried = client.maritalStatus?.lowercased() == "married"
            let annivDays = isMarried ? daysToNextOccasion(dateStr: client.dateOfAnniversary) : nil
            let hasUpcomingOccasions = (bdayDays != nil) || (annivDays != nil)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("UPCOMING OCCASIONS")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1.5)
                
                VStack(spacing: 0) {
                    if let bday = bdayDays {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.surface2)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "gift")
                                    .font(AppFonts.sansSerif(size: 16))
                                    .foregroundStyle(AppColors.gold)
                                    .opacity(0.8)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Birthday in \(bday) days")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                Text(bday == 0 ? "Celebrating today!" : "Upcoming occasion")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    
                    if bdayDays != nil && annivDays != nil {
                        Divider().background(AppColors.gold15)
                    }
                    
                    if let anniv = annivDays {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.surface2)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "heart")
                                    .font(AppFonts.sansSerif(size: 16))
                                    .foregroundStyle(AppColors.gold)
                                    .opacity(0.8)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Anniversary in \(anniv) days")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                Text(anniv == 0 ? "Celebrating today!" : "Upcoming occasion")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    
                    if !hasUpcomingOccasions {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.surface2)
                                    .frame(width: 42, height: 42)
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(AppFonts.sansSerif(size: 16))
                                    .foregroundStyle(AppColors.secondary)
                                    .opacity(0.4)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("No upcoming occasions")
                                    .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                    .foregroundStyle(.white)
                                Text("No anniversary or birthday set")
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                }
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
            }
        }
    }
    
    private func daysToNextOccasion(dateStr: String?) -> Int? {
        guard let dateStr = dateStr, !dateStr.isEmpty else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = dateFormatter.date(from: dateStr) else { return nil }
        
        let calendar = Calendar.current
        let today = Date()
        
        let occasionComponents = calendar.dateComponents([.month, .day], from: date)
        let currentYear = calendar.component(.year, from: today)
        
        var targetComponents = DateComponents()
        targetComponents.year = currentYear
        targetComponents.month = occasionComponents.month
        targetComponents.day = occasionComponents.day
        targetComponents.hour = 0
        targetComponents.minute = 0
        targetComponents.second = 0
        
        guard let targetDateThisYear = calendar.date(from: targetComponents) else { return nil }
        
        let startOfToday = calendar.startOfDay(for: today)
        let startOfTarget = calendar.startOfDay(for: targetDateThisYear)
        
        var finalTargetDate = startOfTarget
        if startOfTarget < startOfToday {
            if let nextYearDate = calendar.date(byAdding: .year, value: 1, to: startOfTarget) {
                finalTargetDate = nextYearDate
            }
        }
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: finalTargetDate)
        return components.day
    }
}

private struct QuickActionButton: View {
    let label: String
    let icon: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(AppFonts.sansSerif(size: 16))
                    .foregroundStyle(AppColors.background)
                Text(label)
                    .font(AppFonts.sansSerif(size: 10, weight: .medium))
                    .foregroundStyle(AppColors.background)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 11)
            .background(AppColors.gold)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct ClientHistoryTab: View {
    let viewModel: ClientDetailViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            let purchases = viewModel.purchases
            if purchases.isEmpty {
                VStack {
                    Text("No purchase history yet")
                        .font(AppFonts.sansSerif(size: 13))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
            } else {
                VStack(spacing: 1) {
                    ForEach(purchases, id: \.id) { p in
                        NavigationLink(value: SARoute.purchaseDetails(client: viewModel.client, purchase: p)) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(AppColors.surface2)
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "handbag")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.gold)
                                        .opacity(0.4)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.name)
                                        .font(AppFonts.sansSerif(size: 12, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(p.date)
                                        .font(AppFonts.sansSerif(size: 11))
                                        .foregroundStyle(AppColors.secondary)
                                }
                                
                                Spacer()
                                
                                Text(CurrencyManager.shared.format(amount: p.price))
                                    .font(AppFonts.serif(size: 13, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 13)
                            .background(AppColors.surface)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
            }
        }
    }
}

private struct ClientWishlistTab: View {
    let viewModel: ClientDetailViewModel
    @State private var showWishlistCatalog = false
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Syncing wishlist...")
                    .tint(AppColors.gold)
                    .foregroundStyle(AppColors.secondary)
                    .padding(.vertical, 32)
                    .frame(maxWidth: .infinity)
            } else {
                let wishlist = viewModel.wishlist
                if wishlist.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(AppFonts.sansSerif(size: 24))
                            .foregroundStyle(AppColors.gold.opacity(0.5))
                        
                        Text("No items in wishlist yet")
                            .font(AppFonts.sansSerif(size: 13))
                            .foregroundStyle(AppColors.secondary)
                        
                        Button(action: {
                            showWishlistCatalog = true
                        }) {
                            Text("Add to Wishlist")
                                .font(AppFonts.sansSerif(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.background)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.gold)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                } else {
                    VStack(spacing: 10) {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showWishlistCatalog = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                    Text("Add Item")
                                }
                                .font(AppFonts.sansSerif(size: 11, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppColors.gold08)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                        }
                        .padding(.bottom, 6)
                        
                        ForEach(wishlist, id: \.id) { w in
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(AppColors.surface2)
                                        .frame(width: 44, height: 44)
                                    
                                    if let imgStr = w.productImages?.first, let imgURL = URL(string: imgStr) {
                                        AsyncImage(url: imgURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 44, height: 44)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            default:
                                                Image(systemName: "circle.grid.cross")
                                                    .font(AppFonts.sansSerif(size: 18))
                                                    .foregroundStyle(AppColors.gold)
                                                    .opacity(0.4)
                                            }
                                        }
                                    } else {
                                        Image(systemName: "circle.grid.cross")
                                            .font(AppFonts.sansSerif(size: 18))
                                            .foregroundStyle(AppColors.gold)
                                            .opacity(0.4)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(w.brand.uppercased())
                                        .font(AppFonts.sansSerif(size: 10))
                                        .foregroundStyle(AppColors.gold)
                                        .kerning(1)
                                    Text(w.name)
                                        .font(AppFonts.serif(size: 14, weight: .medium))
                                        .foregroundStyle(.white)
                                    Text(CurrencyManager.shared.format(amount: w.price))
                                        .font(AppFonts.serif(size: 15, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                
                                Spacer()
                                
                                clientWishlistQuantityControls(for: w)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showWishlistCatalog) {
            WishlistCatalogView(viewModel: viewModel, isPresented: $showWishlistCatalog)
        }
        .onAppear {
            loadWishlist()
        }
        .onChange(of: showWishlistCatalog) { _, isPresented in
            if !isPresented {
                loadWishlist()
            }
        }
    }
    
    @ViewBuilder
    private func clientWishlistQuantityControls(for w: GroupedWishlistItem) -> some View {
        HStack(spacing: 8) {
            Button(action: {
                if let lastItem = w.originalItems.last {
                    Task {
                        await viewModel.removeProductFromWishlist(itemId: lastItem.id)
                        loadWishlist()
                    }
                }
            }) {
                Image(systemName: w.quantity == 1 ? "trash" : "minus")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(w.quantity == 1 ? AppColors.error.opacity(0.8) : AppColors.gold)
                    .frame(width: 26, height: 26)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Text("\(w.quantity)")
                .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                .foregroundStyle(.white)
                .frame(minWidth: 16)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    do {
                        try await viewModel.addProductToWishlist(productId: w.id, brand: w.brand, name: w.name, price: w.price)
                        loadWishlist()
                    } catch {
                        print("Wishlist Tab Quantity Add Error: \(error)")
                    }
                }
            }) {
                Image(systemName: "plus")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.gold)
                    .frame(width: 26, height: 26)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(AppColors.surface2)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
    }
    
    private func loadWishlist() {
        isLoading = true
        Task {
            await WishlistService.shared.syncWishlist(clientId: viewModel.client.id)
            await MainActor.run {
                viewModel.refreshWishlist()
                isLoading = false
            }
        }
    }
}

private struct WishlistProductSelectionView: View {
    let viewModel: ClientDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchVM = SellingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppColors.tertiary)
                        
                        TextField("Search by name or brand…", text: $searchVM.searchText)
                            .font(AppFonts.sansSerif(size: 14))
                            .foregroundStyle(AppColors.text)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.gold15, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    
                    // Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(searchVM.categories, id: \.self) { cat in
                                let isSelected = searchVM.selectedCategory == cat
                                Text(cat.rawValue)
                                    .font(AppFonts.sansSerif(size: 11, weight: isSelected ? .medium : .light))
                                    .foregroundStyle(isSelected ? AppColors.background : AppColors.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? AppColors.gold : Color.clear)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(isSelected ? Color.clear : AppColors.gold15, lineWidth: 0.5)
                                    )
                                    .onTapGesture {
                                        withAnimation {
                                            searchVM.selectedCategory = cat
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    
                    // Product List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(searchVM.filteredCatalogs) { product in
                                Button(action: {
                                    Task {
                                        do {
                                            try await viewModel.addProductToWishlist(
                                                productId: product.id,
                                                brand: product.brand,
                                                name: product.name,
                                                price: product.amount
                                            )
                                            dismiss()
                                        } catch {
                                            print("Wishlist Selection Add Error: \(error)")
                                        }
                                    }
                                }) {
                                    ClientProfileProductRowView(product: product)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Add to Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.sansSerif(size: 14))
                    .foregroundStyle(AppColors.gold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct ClientNotesTab: View {
    let viewModel: ClientDetailViewModel
    
    @State private var showAddNoteSheet = false
    @State private var editingNote: ClientNote? = nil
    @State private var newNoteText = ""
    @State private var editingNoteText = ""
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                
                Button(action: {
                    newNoteText = ""
                    showAddNoteSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add Note")
                    }
                    .font(AppFonts.sansSerif(size: 11, weight: .semibold))
                    .foregroundStyle(AppColors.gold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.gold08)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.gold15, lineWidth: 0.5))
                }
            }
            .padding(.bottom, 2)
            
            let notes = viewModel.notes
            if notes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(AppFonts.sansSerif(size: 24))
                        .foregroundStyle(AppColors.gold.opacity(0.5))
                    Text("No notes recorded yet")
                        .font(AppFonts.sansSerif(size: 13))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
            } else {
                VStack(spacing: 10) {
                    ForEach(notes, id: \.id) { n in
                        SwipeToDeleteNote(note: n, onTap: {
                            editingNoteText = n.note
                            editingNote = n
                        }, onDelete: {
                            Task {
                                await viewModel.deleteNote(noteId: n.id)
                            }
                        })
                    }
                }
            }
        }
        .sheet(isPresented: $showAddNoteSheet) {
            NoteFormView(
                title: "New Note",
                text: $newNoteText,
                onSave: {
                    let text = newNoteText
                    Task {
                        await viewModel.addNote(text: text)
                    }
                }
            )
        }
        .sheet(item: $editingNote) { note in
            NoteFormView(
                title: "Edit Note",
                text: $editingNoteText,
                onSave: {
                    let text = editingNoteText
                    Task {
                        await viewModel.updateNote(noteId: note.id, text: text)
                    }
                }
            )
        }
    }
}

struct SwipeToDeleteNote: View {
    let note: ClientNote
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Trash Action Button
            Button(action: {
                showDeleteAlert = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.error)
                    Image(systemName: "trash.fill")
                        .font(AppFonts.sansSerif(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(width: 70)
            }
            .buttonStyle(.plain)
            .frame(maxHeight: .infinity)
            
            // Note Card Content
            VStack(alignment: .leading, spacing: 8) {
                Text("\"\(note.note)\"")
                    .font(AppFonts.sansSerif(size: 13, weight: .light))
                    .foregroundStyle(.white)
                    .lineSpacing(4)
                
                HStack(spacing: 6) {
                    Circle().fill(AppColors.gold).frame(width: 5, height: 5).opacity(0.6)
                    Text("\(note.author) · \(note.date)")
                    Text("· Encrypted").foregroundStyle(AppColors.tertiary)
                }
                .font(AppFonts.sansSerif(size: 10))
                .foregroundStyle(AppColors.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
            .onTapGesture {
                onTap()
            }
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -250 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = -80
                                isSwiped = true
                            }
                            showDeleteAlert = true
                        } else if value.translation.width < -80 {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = -80
                                isSwiped = true
                            }
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                offset = 0
                                isSwiped = false
                            }
                        }
                    }
            )
        }
        .background(AppColors.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("Delete Note?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        offset = -windowScene.screen.bounds.width
                    } else {
                        offset = -2000
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onDelete()
                }
            }
            Button("Cancel", role: .cancel) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    offset = 0
                    isSwiped = false
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

struct ClientProfileProductRowView: View {
    let product: CatalogEntity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppColors.surface2)
                    .frame(width: 48, height: 48)
                Image(systemName: "circle.grid.cross")
                    .font(AppFonts.sansSerif(size: 16))
                    .foregroundStyle(AppColors.gold)
                    .opacity(0.3)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(product.brand)
                    .font(AppFonts.sansSerif(size: 9, weight: .bold))
                    .foregroundStyle(AppColors.gold)
                    .kerning(1)
                Text(product.name)
                    .font(AppFonts.serif(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                Text(product.formattedPrice)
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.secondary)
            }
            Spacer()
            Image(systemName: "plus.circle.fill")
                .font(AppFonts.sansSerif(size: 20))
                .foregroundStyle(AppColors.gold)
        }
        .padding(12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.gold15, lineWidth: 0.5)
        )
    }
}

struct NoteFormView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Binding var text: String
    let onSave: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 16) {
                    TextEditor(text: $text)
                        .font(AppFonts.sansSerif(size: 14, weight: .light))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.gold15, lineWidth: 0.5)
                        )
                        .scrollContentBackground(.hidden)
                        .focused($isFocused)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    
                    Spacer()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppFonts.sansSerif(size: 14))
                    .foregroundStyle(AppColors.gold)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .font(AppFonts.sansSerif(size: 14, weight: .semibold))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppColors.secondary : AppColors.gold)
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

