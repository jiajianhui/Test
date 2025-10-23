//
//  WeekSwitcherView.swift
//  AIFood
//
//  Created by 贾建辉 on 2025/10/22.
//

import SwiftUI

struct WeekSwitcherView: View {
    
    @State var selectedDate: Date = .now
    @State private var weekOffset: Int = 0
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            // 顶部显示当前周的范围
            Text(weekRangeText)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // 可滑动切换不同周
            TabView(selection: $weekOffset) {
                ForEach(-52...52, id: \.self) { offset in
                    WeekRowView(
                        selectedDate: $selectedDate,
                        baseDate: baseDate(for: offset)
                    )
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 80)
        }
        .animation(.easeInOut, value: weekOffset)
    }

    // MARK: - 工具函数
    private func baseDate(for offset: Int) -> Date {
        calendar.date(byAdding: .weekOfYear, value: offset, to: Date()) ?? Date()
    }

    private var weekRangeText: String {
        let weekDates = datesInWeek(for: baseDate(for: weekOffset))
        guard let first = weekDates.first, let last = weekDates.last else { return "" }

        let f = DateFormatter()
        f.dateFormat = "MM.dd"
        return "\(f.string(from: first)) - \(f.string(from: last))"
    }

    private func datesInWeek(for date: Date) -> [Date] {
        let weekday = calendar.component(.weekday, from: date)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: calendar.startOfDay(for: date))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
}

// MARK: - 子组件：一周7天行
struct WeekRowView: View {
    
    @Binding var selectedDate: Date
    @State var currentDate: Date = .now
    let baseDate: Date
    private let calendar = Calendar.current

    
    // 根据任意日期计算出这一周的 7 天
    private var days: [Date] {
        
        // 1、当前是星期几；Swift 中星期是从 星期日=1 到 星期六=7
        let weekday = calendar.component(.weekday, from: baseDate)
        
        // 2、把当前日期往前回退到“周日”
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: calendar.startOfDay(for: baseDate) // 一天的开始时刻，年月日
        )!
        
        // 3、生成一周的日期数组
        // compactMap 是 map 的变体，对数组中每个元素做变换，同时自动过滤掉 nil 值。
        // *** 从周日开始，依次往后加 0～6 天，生成这一整周的 7 个日期
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    var body: some View {
        HStack(spacing: 16) {
            ForEach(days, id: \.self) { day in
                VStack(spacing: 6) {
                    Text(weekdaySymbol(for: day))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(dayNumber(for: day))
                        .font(.headline)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(bgColor(day))
                        )
                        .foregroundColor(textColor(for: day))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedDate = day
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 文字颜色
    private func textColor(for day: Date) -> Color {
        if isSameDay(day, currentDate) {
            // 选中日期
            return isSameDay(day, selectedDate) ? .white : .blue
        } else {
            return isSameDay(day, selectedDate) ? .white : .primary
        }
    }
    
    // 背景颜色
    func bgColor(_ day: Date) -> Color {
        return isSameDay(day, selectedDate) ? .blue : .clear
    }


    // MARK: - 格式化日期、判断选中状态
    
    // 获取星期几的文本
    private func weekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter() // 将日期转为字符串
        formatter.locale = Locale(identifier: "zh_CN")  // 指定语言环境
        formatter.dateFormat = "EE"  // 显示星期几（简写形式）
        return formatter.string(from: date)
    }

    // 获取日期中的“日”
    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"  // 只要“几号”
        return formatter.string(from: date)
    }

    // 判断两个日期是否是同一天
    private func isSameDay(_ d1: Date, _ d2: Date) -> Bool {
        calendar.isDate(d1, inSameDayAs: d2) // Apple 提供的原生方法
    }
}


#Preview {
    WeekSwitcherView()
}

#Preview {
    WeekRowView(selectedDate: .constant(.now), baseDate: .now)
}
