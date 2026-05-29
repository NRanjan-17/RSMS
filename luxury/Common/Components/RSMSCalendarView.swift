import SwiftUI

struct RSMSCalendarView: View {
    @Binding var selectedDate: Date
    var hasAppointments: ((Date) -> Bool)? = nil
    
    // Helper to format the Month/Year string
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    // Helper to compute weeks in a month
    private func weeksInMonth(for date: Date) -> [[Date?]] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var weeks: [[Date?]] = []
        var currentWeekStart = monthFirstWeek.start
        
        while currentWeekStart < monthInterval.end {
            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let day = calendar.date(byAdding: .day, value: dayOffset, to: currentWeekStart) {
                    if calendar.isDate(day, equalTo: date, toGranularity: .month) {
                        week.append(day)
                    } else {
                        week.append(nil)
                    }
                } else {
                    week.append(nil)
                }
            }
            weeks.append(week)
            
            guard let nextWeek = calendar.date(byAdding: .weekOfMonth, value: 1, to: currentWeekStart) else {
                break
            }
            currentWeekStart = nextWeek
        }
        return weeks
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Month Navigation
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                        .frame(width: 32, height: 32)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthYearString(for: selectedDate))
                    .font(AppFonts.serif(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.gold)
                        .frame(width: 32, height: 32)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 24)
            
            // Calendar Grid
            VStack(spacing: 12) {
                // Weekday headers
                HStack(spacing: 0) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(AppFonts.sansSerif(size: 11, weight: .medium))
                            .foregroundStyle(AppColors.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 24)
                
                // Calendar days
                let weeks = weeksInMonth(for: selectedDate)
                ForEach(0..<weeks.count, id: \.self) { weekIndex in
                    HStack(spacing: 0) {
                        ForEach(0..<7) { dayIndex in
                            if let day = weeks[weekIndex][dayIndex] {
                                let isSelected = Calendar.current.isDate(day, inSameDayAs: selectedDate)
                                let hasAppt = hasAppointments?(day) ?? false
                                let isToday = Calendar.current.isDateInToday(day)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedDate = day
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text("\(Calendar.current.component(.day, from: day))")
                                            .font(AppFonts.sansSerif(size: 14, weight: isSelected ? .semibold : .regular))
                                            .foregroundStyle(isSelected ? AppColors.background : (isToday ? AppColors.gold : AppColors.text))
                                        
                                        if hasAppt {
                                            Circle()
                                                .fill(isSelected ? AppColors.background : AppColors.gold)
                                                .frame(width: 4, height: 4)
                                        } else {
                                            Circle()
                                                .fill(Color.clear)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(isSelected ? AppColors.gold : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            } else {
                                Color.clear
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.gold15, lineWidth: 0.5))
    }
}
