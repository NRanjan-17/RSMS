import SwiftUI

struct EmployeeDetailView: View {
    let employee: StaffModel
    @Environment(Router.self) private var router
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        router.pop()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(AppColors.surface)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Staff Details")
                        .font(AppFonts.serif(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        HStack(spacing: 16) {
                            if let url = URL(string: employee.avatarUrl) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    ZStack {
                                        AppColors.gold08
                                        ProgressView().tint(AppColors.gold).scaleEffect(0.8)
                                    }
                                }
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppColors.gold15, lineWidth: 1))
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.gold08)
                                        .frame(width: 72, height: 72)
                                    Text(String(employee.name.prefix(1)))
                                        .font(AppFonts.serif(size: 28, weight: .semibold))
                                        .foregroundStyle(AppColors.gold)
                                }
                                .overlay(Circle().stroke(AppColors.gold15, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(employee.role.displayName.uppercased())
                                    .font(AppFonts.sansSerif(size: 10, weight: .bold))
                                    .foregroundStyle(AppColors.gold)
                                    .kerning(2)
                                Text(employee.name)
                                    .font(AppFonts.serif(size: 28, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        VStack(spacing: 0) {
                            let details = [
                                ("Employee ID", employee.employeeId),
                                ("Email", employee.email),
                                ("Phone", employee.phone),
                                ("Address", employee.address),
                                ("Location", employee.location),
                                ("City", employee.city),
                                ("Pin Code", employee.pinCode)
                            ]
                            
                            ForEach(0..<details.count, id: \.self) { i in
                                HStack {
                                    Text(details[i].0)
                                        .font(AppFonts.sansSerif(size: 13))
                                        .foregroundStyle(AppColors.secondary)
                                    Spacer()
                                    Text(details[i].1)
                                        .font(AppFonts.sansSerif(size: 14, weight: .medium))
                                        .foregroundStyle(.white)
                                }
                                .padding(.vertical, 16)
                                
                                if i < details.count - 1 {
                                    Divider().background(AppColors.gold15)
                                }
                            }
                        }
                        .padding(20)
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
                        .padding(.horizontal, 24)
                        
                        if let url = URL(string: employee.resumeUrl) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("RESUME")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    HStack {
                                        Spacer()
                                        ProgressView().tint(AppColors.gold)
                                        Spacer()
                                    }
                                    .frame(height: 200)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
