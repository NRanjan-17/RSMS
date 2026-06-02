import SwiftUI
import Charts

struct GlobalRevenueView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = GlobalRevenueViewModel()
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                CustomHeader(
                    title: "Global Revenue",
                    showBackButton: true,
                    backAction: { router.pop() }
                )
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(AppColors.gold)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            
                            // Top KPI
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Revenue")
                                    .font(AppFonts.sansSerif(size: 14))
                                    .foregroundStyle(AppColors.secondary)
                                
                                Text(CurrencyManager.shared.format(amount: viewModel.totalRevenue))
                                    .font(AppFonts.serif(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                                
                                HStack(spacing: 6) {
                                    Text("TODAY:")
                                        .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                        .foregroundStyle(AppColors.secondary)
                                    Text(CurrencyManager.shared.format(amount: viewModel.todayRevenue))
                                        .font(AppFonts.sansSerif(size: 13, weight: .semibold))
                                        .foregroundStyle(AppColors.success)
                                }
                                .padding(.top, 4)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                            .padding(.horizontal, 24)
                            
                            // Timeframe Picker
                            Picker("Timeframe", selection: Binding(
                                get: { viewModel.selectedTimeframe },
                                set: { viewModel.setTimeframe($0) }
                            )) {
                                ForEach(RevenueTimeframe.allCases, id: \.self) { tf in
                                    Text(tf.rawValue).tag(tf)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 24)
                            
                            // Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("\(viewModel.selectedTimeframe.rawValue.uppercased()) REVENUE TREND")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                Chart {
                                    ForEach(viewModel.chartData) { data in
                                        BarMark(
                                            x: .value("Period", data.month),
                                            y: .value("Amount", data.amount)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                gradient: Gradient(colors: [AppColors.gold, AppColors.gold.opacity(0.5)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .cornerRadius(6)
                                    }
                                }
                                .frame(height: 300)
                                .chartYAxis {
                                    AxisMarks(position: .leading) { value in
                                        AxisValueLabel()
                                            .font(AppFonts.sansSerif(size: 10))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                }
                                .chartXAxis {
                                    AxisMarks { value in
                                        AxisValueLabel()
                                            .font(AppFonts.sansSerif(size: 10))
                                            .foregroundStyle(AppColors.tertiary)
                                    }
                                }
                            }
                            .padding(24)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                            .padding(.horizontal, 24)
                            
                            // Transactions List
                            VStack(alignment: .leading, spacing: 16) {
                                Text("RECENT TRANSACTIONS")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                    .padding(.horizontal, 24)
                                
                                if viewModel.transactions.isEmpty {
                                    Text("No recent transactions.")
                                        .font(AppFonts.sansSerif(size: 14))
                                        .foregroundStyle(AppColors.tertiary)
                                        .padding(.horizontal, 24)
                                } else {
                                    LazyVStack(spacing: 12) {
                                        ForEach(viewModel.transactions) { tx in
                                            HStack(spacing: 16) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Order #\(tx.id.uuidString.prefix(8).uppercased())")
                                                        .font(AppFonts.serif(size: 17, weight: .medium))
                                                        .foregroundStyle(.white)
                                                    
                                                    if let date = tx.dateOfPurchase {
                                                        Text(date.formatted(date: .abbreviated, time: .shortened))
                                                            .font(AppFonts.sansSerif(size: 12))
                                                            .foregroundStyle(AppColors.secondary)
                                                    }
                                                }
                                                Spacer()
                                                Text(CurrencyManager.shared.format(amount: tx.totalPrice))
                                                    .font(AppFonts.sansSerif(size: 15, weight: .semibold))
                                                    .foregroundStyle(AppColors.gold)
                                            }
                                            .padding(16)
                                            .background(AppColors.surface)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.gold15, lineWidth: 0.5))
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            
                        }
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.fetchData()
        }
    }
}
