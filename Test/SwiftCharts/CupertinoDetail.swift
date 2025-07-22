//
//  BaseChart.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/22.
//

import SwiftUI
import Charts

struct SalesSummary: Identifiable {
    var id: String { weekday } // 数据的元素 id 是一致的，后面切换时才能有动画
    var weekday: String
    var sales: Int
    
}


private let curpertinoData: [SalesSummary] = [
    .init(weekday: "Mon", sales: 123),
    .init(weekday: "Tue", sales: 241),
    .init(weekday: "Wed", sales: 232),
    .init(weekday: "Thu", sales: 124),
    .init(weekday: "Fri", sales: 232),
    .init(weekday: "Sat", sales: 189),
    .init(weekday: "Sun", sales: 436),
]

struct CupertinoDetail: View {
    var body: some View {
        VStack(alignment: .leading) {
            ChartTitle(title: "CupertinoSales")
            Chart(curpertinoData) { element in
                BarMark(
                    x: .value("week", element.weekday),
                    y: .value("sales", element.sales)
                )
            }
                
            
        }
        .padding()
    }
}



#Preview {
    CupertinoDetail()
}
