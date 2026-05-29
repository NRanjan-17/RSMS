import SwiftUI
import PhotosUI

struct CorporateAdminProfileView: View {
    @Environment(CorporateAdminAppState.self) private var caAppState
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(Router.self) private var router
    @State private var viewModel = SharedProfileViewModel()
    @State private var showLogoutAlert = false
    @State private var currencyManager = CurrencyManager.shared
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: Date()).uppercased()
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(viewModel.roleName.isEmpty ? "CORPORATE ADMIN" : viewModel.roleName.uppercased()) · \(formattedDate)")
                                    .font(AppFonts.sansSerif(size: 10))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(2)
                                    .textCase(.uppercase)
                                Text("Welcome,")
                                    .font(AppFonts.serif(size: 30, weight: .light).italic())
                                    .foregroundStyle(AppColors.text)
                                Text(viewModel.name)
                                    .font(AppFonts.serif(size: 30, weight: .semibold))
                                    .foregroundStyle(AppColors.text)
                            }
                            
                            Spacer()
                            
                            if let avatar = viewModel.avatarUrl, let url = URL(string: avatar) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(AppColors.gold)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 18)
                        
                        // Admin Tools
                        VStack(alignment: .leading, spacing: 16) {
                            Text("ADMIN TOOLS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                adminToolRow(title: "Global Inventory", icon: "shippingbox.fill", route: .globalInventory)
                                adminToolRow(title: "Store Performance", icon: "chart.bar.xaxis", route: .storePerformance)
                                adminToolRow(title: "System Logs", icon: "list.bullet.rectangle.portrait.fill", route: .systemLogs)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                        
                        // Settings
                        VStack(alignment: .leading, spacing: 16) {
                            Text("SETTINGS")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                adminToolRow(title: "Edit Profile", icon: "person.crop.circle", route: .editProfile)
                                
                                NavigationLink(destination: SecuritySettingsView()) {
                                    HStack {
                                        Image(systemName: "lock.shield.fill")
                                            .font(AppFonts.sansSerif(size: 18))
                                            .foregroundStyle(AppColors.gold)
                                            .frame(width: 24, alignment: .center)
                                        Text("Security Settings")
                                            .font(AppFonts.sansSerif(size: 15))
                                            .foregroundStyle(.white)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(AppFonts.sansSerif(size: 12))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                    .padding(16)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                        
                        // Preferences
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREFERENCES")
                                .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                .foregroundStyle(AppColors.secondary)
                                .kerning(1.5)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                HStack {
                                    Text("Global Currency")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Picker("Currency", selection: $currencyManager.currentCurrency) {
                                        ForEach(currencyManager.availableCurrencies, id: \.self) { code in
                                            Text("\(code) (\(currencyManager.symbol(for: code)))").tag(code)
                                        }
                                    }
                                    .tint(AppColors.gold)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            .padding(.horizontal, 24)
                        }
                        .padding(.top, 24)
                        
                        CustomButton(title: "Logout", action: { showLogoutAlert = true })
                            .padding(.horizontal, 24)
                            .padding(.top, 40)
                            .padding(.bottom, 60)
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Logout", role: .destructive) {
                coordinator.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to logout?")
        }
        .task {
            await viewModel.fetchProfile()
        }
    }
    
    @ViewBuilder
    private func adminToolRow(title: String, icon: String, route: CARoute) -> some View {
        Button(action: {
            router.push(route)
        }) {
            HStack {
                Image(systemName: icon)
                    .font(AppFonts.sansSerif(size: 18))
                    .foregroundStyle(AppColors.gold)
                    .frame(width: 24, alignment: .center)
                Text(title)
                    .font(AppFonts.sansSerif(size: 15))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(AppFonts.sansSerif(size: 12))
                    .foregroundStyle(AppColors.tertiary)
            }
            .padding(16)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }
}
