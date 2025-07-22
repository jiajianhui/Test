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
    .init(city: "curpertinoD", sales: curpertinoData),
    .init(city: "San Fracisco", sales: SFData)
]

struct LocationsDetail: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            
            ChartTitle(title: "Location Detail Sales")
            
            // 样式1
            Chart(seriesData) { series in
                ForEach(series.sales) { element in
                    BarMark(
                        x: .value("week", element.weekday),
                        y: .value("sales", element.sales)
                    )
                    .foregroundStyle(by: .value("city", series.city))
                }
            }
            
            Divider()
                .padding(.vertical, 40)
            
            // 样式2
            Chart(seriesData) { series in
                ForEach(series.sales) { element in
                    LineMark(
                        x: .value("week", element.weekday),
                        y: .value("sales", element.sales)
                    )
                    .foregroundStyle(by: .value("city", series.city))
                }
            }
            
            Divider()
                .padding(.vertical, 40)
            
            // 样式3
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
            
        }
        .padding()
    }
}



#Preview {
    LocationsDetail()
}
