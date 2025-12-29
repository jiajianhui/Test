//
//  BaseChart.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/22.
//

import SwiftUI
import Charts


private let sales: [Pancakes] = [
    .init(name: "Cachapa", sales: 98),
    .init(name: "American", sales: 38),
    .init(name: "Injera", sales: 230),
    .init(name: "Dosa", sales: 174),
    .init(name: "Jian Bing", sales: 367)
]

var totalSales: Int {
    sales.reduce(0) { $0 + $1.sales }
}

struct PieChart: View {
    var body: some View {
        ScrollView {
            ChartTitle(title: "Chart")
            
            Chart(sales) { element in
                BarMark(
                    x: .value("scale", element.sales),
                    stacking: .normalized
                )
                .foregroundStyle(by: .value("scale", element.name))
            }
            .chartPlotStyle { plotArea in
                plotArea.frame(height: 40)
            }
            .chartXAxis(.hidden)
            
            
            
            // 饼图
            Chart(sales, id: \.name) { element in
                SectorMark(
                    angle: .value("scale", element.sales),
                    innerRadius: .ratio(0.6),
                    angularInset: 3
                )
                .foregroundStyle(by: .value("scale", element.name))
                .cornerRadius(6)
                .annotation(position: .overlay, alignment: .center, spacing: 10) {
                    
                    let percentage = Double(element.sales) / Double(totalSales) * 100
                    Text("\(percentage, specifier: "%.1f")%")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.frame(height: 360)
            }

            .chartXAxis(.hidden)
            
            .chartLegend(alignment: .center, spacing: 20)
            // 获取图表的尺寸
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    
                    VStack {
                        Text("hello")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Text("PieChart")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            
            
            
        }
        .padding()
    }
}

#Preview {
    PieChart()
}
