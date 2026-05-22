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
                            .font(.system(size: 20, weight: .semibold))
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
                                router.push(SARoute.afterSalesIntake)
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
                    // Logic to save note
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
                QuickActionButton(label: "Appt", icon: "calendar", action: onApptTap)
                QuickActionButton(label: "Note", icon: "square.and.pencil", action: onNoteTap)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("PREFERENCES")
                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.secondary)
                    .kerning(1.5)
                
                if viewModel.preferences.isEmpty {
                    Text("No preferences specified")
                        .font(AppFonts.sansSerif(size: 12))
                        .foregroundStyle(AppColors.secondary)
                        .padding(.vertical, 4)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.preferences, id: \.self) { pref in
                                Text(pref)
                                    .font(AppFonts.sansSerif(size: 11))
                                    .foregroundStyle(AppColors.gold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 5)
                                    .background(AppColors.gold08)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("TICKET TRACKING")
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
                                        .font(.system(size: 12))
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
            
            if viewModel.hasMockData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("UPCOMING")
                        .font(AppFonts.sansSerif(size: 10, weight: .bold))
                        .foregroundStyle(AppColors.secondary)
                        .kerning(1.5)
                    
                    HStack(spacing: 10) {
                        Text("Today 2:30 PM")
                            .font(AppFonts.sansSerif(size: 10, weight: .medium))
                            .foregroundStyle(AppColors.gold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.gold08)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Watch Consultation")
                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                            Text("Arjun Singh · In-Store")
                                .font(AppFonts.sansSerif(size: 11))
                                .foregroundStyle(AppColors.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundStyle(AppColors.tertiary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                }
                
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
                                .font(.system(size: 16))
                                .foregroundStyle(AppColors.gold)
                                .opacity(0.4)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Patek Philippe Nautilus 5711/1A")
                                .font(AppFonts.sansSerif(size: 13, weight: .medium))
                                .foregroundStyle(.white)
                            Text("₹82,00,000 · March 2025")
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
                
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(AppColors.gold08)
                            .frame(width: 36, height: 36)
                        Text("🎂")
                            .font(.system(size: 16))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Birthday in 33 days")
                            .font(AppFonts.sansSerif(size: 12, weight: .medium))
                            .foregroundStyle(AppColors.gold)
                        Text("June 15 · Consider Cartier Love Bracelet")
                            .font(AppFonts.sansSerif(size: 11))
                            .foregroundStyle(AppColors.secondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(AppColors.gold.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold50, lineWidth: 0.5))
            }
        }
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
                    .font(.system(size: 16))
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
        VStack {
            let purchases = viewModel.purchases
            if purchases.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "handbag")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.gold.opacity(0.5))
                    Text("No purchase history yet")
                        .font(AppFonts.sansSerif(size: 13))
                        .foregroundStyle(AppColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(AppColors.surface)
            } else {
                VStack(spacing: 1) {
                    ForEach(purchases, id: \.id) { p in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9)
                                    .fill(AppColors.surface2)
                                    .frame(width: 36, height: 36)
                                Image(systemName: "handbag")
                                    .font(.system(size: 14))
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
                            
                            Text(p.price)
                                .font(AppFonts.serif(size: 13, weight: .semibold))
                                .foregroundStyle(AppColors.gold)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 13)
                        .background(AppColors.surface)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
    }
}

private struct ClientWishlistTab: View {
    let viewModel: ClientDetailViewModel
    @State private var showProductPicker = false
    
    var body: some View {
        VStack {
            let wishlist = viewModel.wishlist
            if wishlist.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppColors.gold.opacity(0.5))
                    
                    Text("No items in wishlist yet")
                        .font(AppFonts.sansSerif(size: 13))
                        .foregroundStyle(AppColors.secondary)
                    
                    Button(action: {
                        showProductPicker = true
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
                            showProductPicker = true
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
                                Image(systemName: "circle.grid.cross")
                                    .font(.system(size: 18))
                                    .foregroundStyle(AppColors.gold)
                                    .opacity(0.4)
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(w.brand.uppercased())
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(1)
                                Text(w.name)
                                    .font(AppFonts.serif(size: 14, weight: .medium))
                                    .foregroundStyle(.white)
                                Text(w.price)
                                    .font(AppFonts.serif(size: 15, weight: .semibold))
                                    .foregroundStyle(AppColors.gold)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                // Minus/Trash Button
                                Button(action: {
                                    if let lastItem = w.originalItems.last {
                                        Task {
                                            await viewModel.removeProductFromWishlist(itemId: lastItem.id)
                                        }
                                    }
                                }) {
                                    Image(systemName: w.quantity == 1 ? "trash" : "minus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(w.quantity == 1 ? Color.red.opacity(0.8) : AppColors.gold)
                                        .frame(width: 26, height: 26)
                                        .background(AppColors.surface)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                                
                                // Quantity Text
                                Text("\(w.quantity)")
                                    .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 16)
                                    .multilineTextAlignment(.center)
                                
                                // Plus Button
                                Button(action: {
                                    Task {
                                        await viewModel.addProductToWishlist(brand: w.brand, name: w.name, price: w.price)
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
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
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                    }
                }
            }
        }
        .sheet(isPresented: $showProductPicker) {
            WishlistProductSelectionView(viewModel: viewModel)
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
                                Text(cat)
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
                            ForEach(searchVM.filteredProducts) { product in
                                Button(action: {
                                    Task {
                                        await viewModel.addProductToWishlist(
                                            brand: product.brand,
                                            name: product.name,
                                            price: product.price
                                        )
                                        dismiss()
                                    }
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(AppColors.surface2)
                                                .frame(width: 48, height: 48)
                                            Image(systemName: "circle.grid.cross")
                                                .font(.system(size: 16))
                                                .foregroundStyle(AppColors.gold)
                                                .opacity(0.3)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(product.brand.uppercased())
                                                .font(AppFonts.sansSerif(size: 9, weight: .bold))
                                                .foregroundStyle(AppColors.gold)
                                                .kerning(1)
                                            Text(product.name)
                                                .font(AppFonts.serif(size: 14, weight: .medium))
                                                .foregroundStyle(.white)
                                            Text(product.price)
                                                .font(AppFonts.sansSerif(size: 12))
                                                .foregroundStyle(AppColors.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 20))
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
    var body: some View {
        VStack {
            let notes = viewModel.notes
            if notes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 24))
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\"\(n.note)\"")
                                .font(AppFonts.sansSerif(size: 13, weight: .light))
                                .foregroundStyle(.white)
                                .lineSpacing(4)
                            
                            HStack(spacing: 6) {
                                Circle().fill(AppColors.gold).frame(width: 5, height: 5).opacity(0.6)
                                Text("\(n.author) · \(n.date)")
                                Text("· Encrypted").foregroundStyle(AppColors.tertiary)
                            }
                            .font(AppFonts.sansSerif(size: 10))
                            .foregroundStyle(AppColors.secondary)
                        }
                        .padding(14)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                    }
                }
            }
        }
    }
}
