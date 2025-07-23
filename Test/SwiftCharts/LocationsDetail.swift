//
//  BaseChart.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/22.
//

import SwiftUI
import Charts




private let curpertinoData: [SalesSummary] = [
    .init(weekday: "Mon", sales: 123),
    .init(weekday: "Tue", sales: 241),
    .init(weekday: "Wed", sales: 232),
    .init(weekday: "Thu", sales: 124),
    .init(weekday: "Fri", sales: 232),
    .init(weekday: "Sat", sales: 189),
    .init(weekday: "Sun", sales: 436),
]
private let SFData: [SalesSummary] = [
    .init(weekday: "Mon", sales: 453),
    .init(weekday: "Tue", sales: 151),
    .init(weekday: "Wed", sales: 143),
    .init(weekday: "Thu", sales: 232),
    .init(weekday: "Fri", sales: 232),
    .init(weekday: "Sat", sales: 401),
    .init(weekday: "Sun", sales: 236),
]

// 为该图标设计的结构
struct Series: Identifiable {
    var city: String
    var sales: [SalesSummary]
    
    var id: String { city }
}

private let seriesData: [Series] = [
    .init(city: "Curpertino", sales: curpertinoData),
    .init(city: "San Fracisco", sales: SFData)
]

struct LocationsDetail: View {
    
    var body: some View {
        ScrollView {
            ChartTitle(title: "Location Detail Sales")
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 60) {
                
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        BarMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                    }
                }
                
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        BarMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                        .position(by: .value("city", series.city))
                    }
                }
                // 更改chart颜色
                .chartForegroundStyleScale([
                    "Curpertino": .purple,
                    "San Fracisco": .orange,
                ])
                .chartYAxis {
                    AxisMarks(preset: .extended, position: .leading)
                }
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        BarMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                        .position(by: .value("city", series.city))
                    }
                }
                // 更改chart颜色
                .chartForegroundStyleScale([
                    "Curpertino": .red,
                    "San Fracisco": .cyan,
                ])
                // 移除坐标轴、图例
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        LineMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                    }
                }
                .chartPlotStyle { plotArea in
                    plotArea.background(.pink.opacity(0.2))
                        .border(.pink, width: 1)
                }
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        LineMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                        .symbol(by: .value("city", series.city))
                    }
                }
                
                
                
                
                Chart(seriesData) { series in
                    ForEach(series.sales) { element in
                        LineMark(
                            x: .value("week", element.weekday),
                            y: .value("sales", element.sales)
                        )
                        .foregroundStyle(by: .value("city", series.city))
                        .symbol(by: .value("city", series.city))
                        .interpolationMethod(.catmullRom)
                    }
                }
                
            }
            // 更改绘图区的尺寸
            .chartPlotStyle { plotArea in
                plotArea.frame(height: 160)
            }
            .padding()
        }
    }
}



#Preview {
    LocationsDetail()
}
