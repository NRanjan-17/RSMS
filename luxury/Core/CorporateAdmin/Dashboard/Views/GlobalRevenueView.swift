import SwiftUI
import Charts

struct GlobalRevenueView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = GlobalAnalyticsViewModel()
    
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
                                
                                Text(CurrencyManager.shared.format(amount: viewModel.kpis.first(where: { $0.label == "Global Revenue" })?.type.value ?? 0))
                                    .font(AppFonts.serif(size: 36, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 1))
                            .padding(.horizontal, 24)
                            
                            // Chart
                            VStack(alignment: .leading, spacing: 16) {
                                Text("MONTHLY REVENUE TREND")
                                    .font(AppFonts.sansSerif(size: 11, weight: .bold))
                                    .foregroundStyle(AppColors.secondary)
                                    .kerning(1.5)
                                
                                Chart {
                                    ForEach(viewModel.revenueChartData) { data in
                                        BarMark(
                                            x: .value("Month", data.month),
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
                            
                        }
                        .padding(.vertical, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchData()
        }
    }
}

extension KPIType {
    var value: Double {
        switch self {
        case .currency(let val): return val
        default: return 0
        }
    }
}
